//
//  SupabaseService.swift
//  Autism
//
//  Phase 4: Essential Security Features (Simplified)
//

import Foundation
@_exported import Supabase
import SwiftUI

// MARK: - Supabase Authentication Service
@MainActor
class SupabaseService: ObservableObject {
    // MARK: - Properties
    private let supabase: SupabaseClient
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var currentProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Security Settings
    private let maxRetryAttempts = 3
    private var retryCount = 0
    
    // MARK: - Initialization
    init() {
        // Initialize optional properties
        self.currentUser = nil
        self.currentProfile = nil
        self.errorMessage = nil
        
        // Get credentials from Info.plist
        guard let supabaseURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
              let url = URL(string: supabaseURL) else {
            fatalError("Supabase credentials not found in Info.plist")
        }
        
        // Initialize Supabase client
        self.supabase = SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseKey
        )
        
        print("✅ Supabase Service initialized successfully")
        
        // Setup app lifecycle observers for session validation
        setupAppLifecycleObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - App Lifecycle Management
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        // Verify session is still valid when app becomes active
        Task {
            await validateCurrentSession()
        }
    }
    
    // MARK: - Session State Persistence
    private func saveSessionState() {
        let defaults = UserDefaults.standard
        defaults.set(isAuthenticated, forKey: "supabase_authenticated")
        defaults.set(currentUser?.id.uuidString, forKey: "supabase_user_id")
    }
    
    private func clearStoredSessionState() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "supabase_authenticated")
        defaults.removeObject(forKey: "supabase_user_id")
    }
    
    // MARK: - Authentication Methods
    
    /// Sign up a new user with email and password
    func signUp(email: String, password: String, fullName: String, role: UserRole) async throws {
        isLoading = true
        errorMessage = nil
        retryCount = 0
        
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: [
                    "full_name": .string(fullName),
                    "role": .string(role.rawValue)
                ]
            )
            
            let user = response.user
            await updateAuthenticationState(user: user)
            
            // Create profile in the users table
            try await createUserProfile(
                userId: user.id,
                email: email,
                name: fullName,
                role: role
            )
            
            print("✅ User signed up successfully: \(email)")
            
        } catch {
            await handleAuthError(error)
            throw error
        }
        
        isLoading = false
    }
    
    /// Sign in existing user with email and password
    func signIn(email: String, password: String) async throws -> UserRole {
        isLoading = true
        errorMessage = nil
        retryCount = 0
        
        do {
            let response = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            let user = response.user
            await updateAuthenticationState(user: user)
            
            // Fetch user profile to get role
            let profile = try await fetchUserProfile(userId: user.id)
            
            print("✅ User signed in successfully: \(email)")
            return profile.role
            
        } catch {
            await handleAuthError(error)
            throw error
        }
        
        isLoading = false
    }
    
    /// Sign out current user with comprehensive cleanup
    func signOut() async throws {
        isLoading = true
        
        do {
            // Sign out from Supabase
            try await supabase.auth.signOut()
            
            // Clear all state
            await clearAuthenticationState()
            
            print("✅ User signed out successfully")
            
        } catch {
            await handleAuthError(error)
            throw error
        }
        
        isLoading = false
    }
    
    /// Reset password for user
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            print("✅ Password reset email sent to: \(email)")
        } catch {
            await handleAuthError(error)
            throw error
        }
        
        isLoading = false
    }
    
    // Delete user account permanently
    func deleteAccount() async throws {
        guard let currentUser = currentUser else {
            throw SupabaseAuthError.userNotFound
        }
        
        // Remove the unused currentProfile check since we only need the user ID
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Delete from the users table (custom table)
            try await supabase
                .from("users")
                .delete()
                .eq("id", value: currentUser.id)
                .execute()
            
            print("✅ User profile deleted from database")
            
            // Sign out and clear all state
            await clearAuthenticationState()
            
            print("✅ Account deletion completed successfully")
            
        } catch {
            await handleAuthError(error)
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Profile Management
    
    /// Create user profile in the users table
    private func createUserProfile(userId: UUID, email: String, name: String, role: UserRole) async throws {
        struct InsertProfile: Encodable {
            let id: UUID
            let email: String
            let name: String
            let role: String
            let is_active: Bool
        }
        
        let profileData = InsertProfile(
            id: userId,
            email: email,
            name: name,
            role: role.rawValue,
            is_active: true
        )
        
        try await supabase
            .from("users")
            .insert(profileData)
            .execute()
        
        print("✅ User profile created in database")
    }
    
    /// Fetch user profile from the users table
    func fetchUserProfile(userId: UUID) async throws -> UserProfile {
        let response: [UserProfile] = try await supabase
            .from("users")
            .select("*")
            .eq("id", value: userId)
            .execute()
            .value
        
        guard let profile = response.first else {
            throw SupabaseAuthError.userNotFound
        }
        
        await MainActor.run {
            self.currentProfile = profile
        }
        
        return profile
    }
    
    /// Update user profile
    func updateUserProfile(_ profile: UserProfile) async throws {
        struct UpdateProfile: Encodable {
            let name: String
            let phone: String?
            let location: String?
            let bio: String?
            let updated_at: String
        }
        
        let updateData = UpdateProfile(
            name: profile.name,
            phone: profile.phone,
            location: profile.location,
            bio: profile.bio,
            updated_at: ISO8601DateFormatter().string(from: Date())
        )
        
        try await supabase
            .from("users")
            .update(updateData)
            .eq("id", value: profile.id)
            .execute()
        
        await MainActor.run {
            self.currentProfile = profile
        }
        
        print("✅ User profile updated")
    }
    
    // MARK: - Session Management & Validation
    
    /// Check current authentication status with enhanced validation
    func checkAuthenticationStatus() async {
        do {
            let session = try await supabase.auth.session
            
            // Validate session has required data
            guard !session.accessToken.isEmpty else {
                await clearAuthenticationState()
                return
            }
            
            let user = session.user
            await updateAuthenticationState(user: user)
            
            // Fetch user profile
            _ = try await fetchUserProfile(userId: user.id)
            
        } catch {
            await clearAuthenticationState()
            print("⚠️ Auth status check failed: \(error)")
        }
    }
    
    /// Validate current session and handle expiry
    private func validateCurrentSession() async {
        guard isAuthenticated else { return }
        
        do {
            let session = try await supabase.auth.session
            
            // If we can get the session, it's still valid
            if !session.accessToken.isEmpty {
                print("✅ Session is still valid")
                return
            }
            
            // Session is invalid
            print("⚠️ Session is no longer valid, signing out")
            await clearAuthenticationState()
            
        } catch {
            print("⚠️ Session validation failed: \(error)")
            await clearAuthenticationState()
        }
    }
    
    // MARK: - State Management
    
    /// Update authentication state when user logs in
    private func updateAuthenticationState(user: User) async {
        await MainActor.run {
            self.currentUser = user
            self.isAuthenticated = true
            self.errorMessage = nil
        }
        
        saveSessionState()
    }
    
    /// Clear authentication state when user logs out
    private func clearAuthenticationState() async {
        await MainActor.run {
            self.currentUser = nil
            self.currentProfile = nil
            self.isAuthenticated = false
            self.errorMessage = nil
        }
        
        clearStoredSessionState()
    }
    
    /// Handle authentication errors with enhanced categorization
    private func handleAuthError(_ error: Error) async {
        await MainActor.run {
            let errorDescription = error.localizedDescription.lowercased()
            
            // Categorize errors more comprehensively
            if errorDescription.contains("invalid") || errorDescription.contains("credentials") {
                self.errorMessage = "Invalid email or password"
            } else if errorDescription.contains("not found") || errorDescription.contains("user") {
                self.errorMessage = "User not found"
            } else if errorDescription.contains("weak") || errorDescription.contains("password") {
                self.errorMessage = "Password is too weak (minimum 6 characters)"
            } else if errorDescription.contains("already") || errorDescription.contains("exists") {
                self.errorMessage = "Email is already registered"
            } else if errorDescription.contains("network") || errorDescription.contains("connection") {
                self.errorMessage = "Network error. Please check your connection"
            } else if errorDescription.contains("timeout") {
                self.errorMessage = "Request timed out. Please try again"
            } else if errorDescription.contains("rate") || errorDescription.contains("limit") {
                self.errorMessage = "Too many attempts. Please wait before trying again"
            } else if errorDescription.contains("session") || errorDescription.contains("expired") {
                self.errorMessage = "Session expired. Please sign in again"
            } else {
                self.errorMessage = "Authentication failed. Please try again"
            }
            
            print("⚠️ Auth error: \(self.errorMessage ?? "Unknown error")")
        }
    }
}

// MARK: - User Profile Model (unchanged from previous version)
struct UserProfile: Codable, Identifiable {
    let id: UUID
    let email: String
    let name: String
    let phone: String?
    let location: String?
    let bio: String?
    let role: UserRole
    let avatarUrl: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, phone, location, bio, role
        case avatarUrl = "avatar_url"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle UUID conversion
        if let uuid = try? container.decode(UUID.self, forKey: .id) {
            self.id = uuid
        } else {
            let idString = try container.decode(String.self, forKey: .id)
            guard let uuid = UUID(uuidString: idString) else {
                throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "Invalid UUID string")
            }
            self.id = uuid
        }
        
        self.email = try container.decode(String.self, forKey: .email)
        self.name = try container.decode(String.self, forKey: .name)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        
        // Handle UserRole conversion
        let roleString = try container.decode(String.self, forKey: .role)
        guard let userRole = UserRole(rawValue: roleString) else {
            throw DecodingError.dataCorruptedError(forKey: .role, in: container, debugDescription: "Invalid role: \(roleString)")
        }
        self.role = userRole
        
        self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        self.isActive = try container.decode(Bool.self, forKey: .isActive)
        
        // Handle date conversion
        let dateFormatter = ISO8601DateFormatter()
        
        if let createdDate = try? container.decode(Date.self, forKey: .createdAt) {
            self.createdAt = createdDate
        } else {
            let createdAtString = try container.decode(String.self, forKey: .createdAt)
            guard let createdDate = dateFormatter.date(from: createdAtString) else {
                throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Invalid date format")
            }
            self.createdAt = createdDate
        }
        
        if let updatedDate = try? container.decode(Date.self, forKey: .updatedAt) {
            self.updatedAt = updatedDate
        } else {
            let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
            guard let updatedDate = dateFormatter.date(from: updatedAtString) else {
                throw DecodingError.dataCorruptedError(forKey: .updatedAt, in: container, debugDescription: "Invalid date format")
            }
            self.updatedAt = updatedDate
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encode(role.rawValue, forKey: .role)
        try container.encodeIfPresent(avatarUrl, forKey: .avatarUrl)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

// MARK: - UserProfile Extension
extension UserProfile {
    /// Regular initializer for creating UserProfile instances
    init(
        id: UUID,
        email: String,
        name: String,
        phone: String? = nil,
        location: String? = nil,
        bio: String? = nil,
        role: UserRole,
        avatarUrl: String? = nil,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.phone = phone
        self.location = location
        self.bio = bio
        self.role = role
        self.avatarUrl = avatarUrl
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Custom Auth Errors
enum SupabaseAuthError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists
    case weakPassword
    case networkError
    case sessionExpired
    case rateLimitExceeded
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "User account not found"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .weakPassword:
            return "Password is too weak"
        case .networkError:
            return "Network connection error"
        case .sessionExpired:
            return "Your session has expired. Please sign in again"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later"
        case .unknownError:
            return "An unexpected error occurred"
        }
    }
}
