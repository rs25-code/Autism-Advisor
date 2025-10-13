//
//  AppState.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI
import Foundation

// MARK: - App State Manager
@MainActor
class AppState: ObservableObject {
    // MARK: - Navigation State
    @Published var currentScreen: Screen = .landing
    @Published var userRole: UserRole? = nil
    @Published var isLoggedIn: Bool = false
    @Published var demoMode: Bool = false
    
    // MARK: - Supabase Integration
    @Published var supabaseService = SupabaseService()
    
    // MARK: - Document State
    @Published var currentIEP: IEPData? = nil
    @Published var uploadSession: UploadSession? = nil
    @Published var chatSession: ChatSession? = nil
    @Published var documentHistory: [IEPData] = []
    
    // MARK: - Services
    private let baseOpenAIService = OpenAIService()
    lazy var openAIService = MultilingualOpenAIService(openAIService: baseOpenAIService)
    let documentProcessor = DocumentProcessor()
    
    // MARK: - Language Support
    @Published var languagePreferences = LanguagePreferences()
    
    // MARK: - UI State
    @Published var isProcessingDocument = false
    @Published var showingDocumentPicker = false
    @Published var showingErrorAlert = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Phase 4: Security Features (Added)
    @Published var showingSessionExpiredAlert = false
    @Published var isPerformingSecureOperation = false
    
    enum Screen: Hashable {
        case landing
        case roleSelection
        case login
        case signup
        case dashboard
        case upload
        case analysis
        case qa
        case profile
    }
    
    // MARK: - Initialization
    init() {
        // Don't auto-check authentication on startup
        // This allows users to go through the normal flow
        // Authentication will be checked when explicitly needed
    }
    
    // MARK: - Device Detection
    var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // MARK: - Authentication State Observation
    private func observeAuthenticationState() async {
        await supabaseService.checkAuthenticationStatus()
        
        // Only auto-login if we're on the landing screen and user is authenticated
        // This prevents interrupting navigation flows like role selection -> login
        if supabaseService.isAuthenticated,
           let profile = supabaseService.currentProfile,
           currentScreen == .landing {
            await updateAuthenticationState(profile: profile)
        }
    }

    // MARK: - Explicit session checking
    
        func checkForExistingSession() async {
            await supabaseService.checkAuthenticationStatus()
            
            // Only auto-login if user is authenticated AND we want to bypass normal flow
            // For now, let's disable auto-login to ensure proper navigation flow
            if supabaseService.isAuthenticated,
               let profile = supabaseService.currentProfile {
                // User has valid session but we'll let them go through normal flow
                // This ensures the landing -> role selection flow works as expected
                
                // Optional: You could store this info for later use
                // self.hasExistingSession = true
                
                // Don't automatically update state here - let user choose their path
                print("✅ Found existing session for user: \(profile.name)")
            } else {
                // No existing session
                self.isLoggedIn = false
                print("ℹ️ No existing session found")
            }
        }
    
    // MARK: - Navigation Methods
    func navigate(to screen: Screen) {
        self.currentScreen = screen
    }
    
    // MARK: - Authentication Methods
    
    func proceedToLogin(with role: UserRole) {
        // Set the role and navigate to login screen
        self.userRole = role
        self.currentScreen = .login
        
        // Don't auto-check authentication here - let user choose to login or signup
    }
    
    func signUp(email: String, password: String, fullName: String) async {
        guard let selectedRole = userRole else {
            showError("Please select a role first")
            return
        }
        
        isPerformingSecureOperation = true
        
        do {
            try await supabaseService.signUp(
                email: email,
                password: password,
                fullName: fullName,
                role: selectedRole
            )
            
            await proceedToDashboard()
            
        } catch {
            showError("Sign up failed: \(error.localizedDescription)")
        }
        
        isPerformingSecureOperation = false
    }
    
    func signIn(email: String, password: String) async {
        isPerformingSecureOperation = true
        
        do {
            let userRole = try await supabaseService.signIn(
                email: email,
                password: password
            )
            
            self.userRole = userRole
            await proceedToDashboard()
            
        } catch {
            showError("Sign in failed: \(error.localizedDescription)")
        }
        
        isPerformingSecureOperation = false
    }
    
    private func proceedToDashboard() async {
        self.isLoggedIn = true
        self.currentScreen = .dashboard
    }
    
    private func updateAuthenticationState(profile: UserProfile) async {
        self.userRole = profile.role
        self.isLoggedIn = true
        self.currentScreen = .dashboard
    }
    
    func login(as role: UserRole) {
        self.userRole = role
        self.isLoggedIn = true
        self.demoMode = true
        self.currentScreen = .dashboard
    }
    
    // MARK: - Enhanced Logout (Phase 4 Security)
    func logout() {
        // Perform secure logout in background if not demo mode
        if !demoMode {
            Task {
                try? await supabaseService.signOut()
            }
        }
        
        // Clear all state immediately
        self.userRole = nil
        self.isLoggedIn = false
        self.demoMode = false
        self.currentIEP = nil
        self.uploadSession = nil
        self.chatSession = nil
        self.documentHistory.removeAll()
        self.currentScreen = .landing
        
        // Clear security states
        self.showingSessionExpiredAlert = false
        self.isPerformingSecureOperation = false
        self.errorMessage = nil
        self.showingErrorAlert = false
    }
    
    // MARK: - Document Upload Management
    func startUploadSession() {
        self.uploadSession = UploadSession()
    }
    
    func processSelectedDocument(url: URL) async {
        guard var session = uploadSession else {
            showError("No active upload session")
            return
        }
        
        session.status = .processingDocument
        
        self.uploadSession = session
        self.isProcessingDocument = true
        
        do {
            let processedDocument = try await documentProcessor.processDocument(from: url)
            
            session.status = .analyzingDocument
            self.uploadSession = session
            
            let studentName = IEPData.extractStudentName(
                from: processedDocument.extractedText,
                fileName: processedDocument.originalFileName
            )
            
            let analysis = try await openAIService.analyzeDocument(
                processedDocument.extractedText,
                studentName: studentName
            )
            
            let iepData = analysis.toIEPData(
                fileName: processedDocument.originalFileName,
                originalDocument: processedDocument
            )
            
            session.status = .completed
            
            self.currentIEP = iepData
            self.documentHistory.insert(iepData, at: 0)
            self.uploadSession = session
            self.isProcessingDocument = false
            self.currentScreen = .analysis
            
        } catch {
            session.status = .failed
            
            self.uploadSession = session
            self.isProcessingDocument = false
            
            showError("Failed to process document: \(error.localizedDescription)")
        }
    }
    
    func completeUpload() {
        self.uploadSession = nil
    }
    
    func cancelUpload() {
        self.uploadSession = nil
        self.isProcessingDocument = false
    }
    
    // Legacy method names for compatibility
    func completeUploadSession() {
        completeUpload()
    }
    
    func cancelUploadSession() {
        cancelUpload()
    }
    
    // MARK: - Document Management
    func selectDocument(_ iepData: IEPData) {
        self.currentIEP = iepData
        self.chatSession = nil
    }
    
    // MARK: - Chat Session Management
    func startChatSession() {
        guard let currentDocument = currentIEP else {
            showError("No document available for chat")
            return
        }
        
        self.chatSession = ChatSession(
            documentId: currentDocument.documentId,
            studentName: currentDocument.studentName,
            fileName: currentDocument.fileName
        )
    }
    
    func endChatSession() {
        self.chatSession = nil
    }
    
    // MARK: - Error Handling (Simplified for Phase 4)
    func showError(_ message: String) {
        self.errorMessage = message
        self.showingErrorAlert = true
    }
    
    func clearError() {
        self.errorMessage = nil
        self.showingErrorAlert = false
    }
    
    // MARK: - Navigation State Helpers
    var shouldUseSidebar: Bool {
        return isLoggedIn &&
               currentScreen != .landing &&
               currentScreen != .roleSelection &&
               currentScreen != .login &&
               currentScreen != .signup &&
               isPad
    }
    
    var shouldUseTabBar: Bool {
        return isLoggedIn &&
               currentScreen != .landing &&
               currentScreen != .roleSelection &&
               currentScreen != .login &&
               currentScreen != .signup &&
               isPhone
    }
    
    // MARK: - Computed Properties for UI State
    var canStartUpload: Bool {
        return uploadSession == nil && !isProcessingDocument
    }
    
    var canStartChat: Bool {
        return currentIEP != nil && chatSession == nil
    }
    
    var hasActiveDocument: Bool {
        return currentIEP != nil
    }
    
    var hasDocumentHistory: Bool {
        return !documentHistory.isEmpty
    }
    
    var uploadProgress: Double {
        switch uploadSession?.status {
        case .idle: return 0.0
        case .selectingFile: return 0.1
        case .processingDocument: return documentProcessor.processingProgress * 0.5
        case .analyzingDocument: return 0.5 + (openAIService.isLoading ? 0.4 : 0.5)
        case .completed: return 1.0
        case .failed: return 0.0
        case .none: return 0.0
        }
    }
    
    var uploadStatusText: String {
        return uploadSession?.status.displayText ?? "Ready to upload"
    }
    
    var isChatActive: Bool {
        return chatSession != nil && hasActiveDocument
    }
    
    var chatMessageCount: Int {
        return chatSession?.messageCount ?? 0
    }
    
    // MARK: - Navigation Helpers
    func navigateToChat() {
        if self.chatSession == nil {
            self.startChatSession()
        }
        self.navigate(to: .qa)
    }
    
    func navigateToAnalysis() {
        if currentIEP != nil {
            self.navigate(to: .analysis)
        } else {
            showError("No document available for analysis")
        }
    }
    
    func navigateToUpload() {
        self.navigate(to: .upload)
        
        if self.canStartUpload {
            self.startUploadSession()
        }
    }
    
    // MARK: - Chat Management Methods
    func clearChatSession() {
        endChatSession()
    }

    func sendMessage(_ message: String) async {
        guard let session = chatSession,
              let iep = currentIEP,
              let document = iep.originalDocument else {
            showError("No active chat session or document")
            return
        }
        
        // Add user message
        let userMessage = Message(text: message, isFromUser: true)
        if var currentSession = self.chatSession {
            currentSession.addMessage(userMessage)
            self.chatSession = currentSession
        }
        
        // Get AI response
        do {
            let response = try await openAIService.askQuestion(
                message,
                about: document.extractedText,
                chatHistory: session.messages
            )
            
            let aiMessage = Message(text: response, isFromUser: false)
            if var currentSession = self.chatSession {
                currentSession.addMessage(aiMessage)
                self.chatSession = currentSession
            }
        } catch {
            showError("Failed to get response: \(error.localizedDescription)")
        }
    }
}
