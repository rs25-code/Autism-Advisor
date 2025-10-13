//
//  ProfileScreen.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var isEditing = false
    @State private var showingLogoutAlert = false
    @State private var showingRoleChange = false
    @State private var isLoadingProfile = false
    @State private var isUpdatingProfile = false
    
    // Account deletion states
    @State private var showingDeleteAccountAlert = false
    @State private var showingDeleteConfirmation = false
    @State private var deleteConfirmationText = ""
    @State private var isDeletingAccount = false
    @State private var showingAccountDeletedAlert = false
    
    // Editable profile fields
    @State private var editableName: String = ""
    @State private var editablePhone: String = ""
    @State private var editableLocation: String = ""
    @State private var editableBio: String = ""
    
    // Preferences (local storage for now)
    @State private var emailNotifications: Bool = true
    @State private var pushNotifications: Bool = true
    @State private var analyticsEnabled: Bool = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoadingProfile {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading profile...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile Header
                            profileHeaderSection
                            
                            // Contact Information
                            contactInformationSection
                            
                            // Activity Summary
                            activitySummarySection
                            
                            // Preferences
                            preferencesSection
                            
                            // Account Actions
                            accountActionsSection
                        }
                        .padding(.horizontal, appState.isPad ? 24 : 16)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            saveProfile()
                        } else {
                            startEditing()
                        }
                    }
                    .fontWeight(.medium)
                    .disabled(isUpdatingProfile)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Continue", role: .destructive) {
                showingDeleteConfirmation = true
            }
        } message: {
            Text("This action is irreversible and cannot be recovered. All your data will be permanently deleted.")
        }
        .alert("Account Deleted", isPresented: $showingAccountDeletedAlert) {
            Button("Log Out") {
                appState.logout()
            }
        } message: {
            Text("Your account has been permanently deleted. Click the logoff button to logout.")
        }
        .sheet(isPresented: $showingRoleChange) {
            RoleChangeSheet()
        }
        .sheet(isPresented: $showingDeleteConfirmation) {
            DeleteAccountConfirmationView(
                deleteConfirmationText: $deleteConfirmationText,
                isDeletingAccount: $isDeletingAccount,
                onCancel: {
                    showingDeleteConfirmation = false
                    deleteConfirmationText = ""
                },
                onDelete: deleteAccount
            )
        }
        .onAppear {
            loadProfile()
        }
    }
    
    // MARK: - Profile Header Section
    private var profileHeaderSection: some View {
        VStack(spacing: 20) {
            // Avatar and basic info
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 100, height: 100)
                    
                    Text(initials)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTheme.primary)
                    
                    if isEditing {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    // TODO: Implement avatar photo picker
                                }) {
                                    Image(systemName: "camera.fill")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .frame(width: 28, height: 28)
                                        .background(Circle().fill(ColorTheme.primary))
                                }
                            }
                        }
                        .frame(width: 100, height: 100)
                    }
                }
                
                VStack(spacing: 8) {
                    if isEditing {
                        TextField("Full Name", text: $editableName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(displayName)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    // Role badge
                    Text(currentUserRole?.displayName ?? "Unknown Role")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(currentUserRole?.color.opacity(0.1) ?? Color.gray.opacity(0.1))
                        .foregroundColor(currentUserRole?.color ?? .gray)
                        .cornerRadius(20)
                    
                    // Member since
                    Text("Member since \(memberSinceText)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Contact Information Section
    private var contactInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                ProfileField(
                    icon: "envelope.fill",
                    label: "Email",
                    value: .constant(currentEmail),
                    isEditing: false // Email can't be edited for now
                )
                
                ProfileField(
                    icon: "phone.fill",
                    label: "Phone",
                    value: $editablePhone,
                    isEditing: isEditing
                )
                
                ProfileField(
                    icon: "location.fill",
                    label: "Location",
                    value: $editableLocation,
                    isEditing: isEditing
                )
                
                ProfileField(
                    icon: "text.alignleft",
                    label: "Bio",
                    value: $editableBio,
                    isEditing: isEditing
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Activity Summary Section
    private var activitySummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: appState.isPad ? 4 : 2), spacing: 16) {
                ForEach(getActivityStats(), id: \.title) { stat in
                    ActivityStatCard(stat: stat)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Preferences Section
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                PreferenceToggle(
                    title: "Email Notifications",
                    subtitle: "Receive updates via email",
                    isOn: $emailNotifications
                )
                
                PreferenceToggle(
                    title: "Push Notifications",
                    subtitle: "Get notified about important updates",
                    isOn: $pushNotifications
                )
                
                PreferenceToggle(
                    title: "Data Analytics",
                    subtitle: "Help improve the app experience",
                    isOn: $analyticsEnabled
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Account Actions Section
    private var accountActionsSection: some View {
        VStack(spacing: 12) {
            ActionButton(
                title: "Export My Data",
                icon: "square.and.arrow.up",
                color: .blue
            ) {
                exportUserData()
            }
            
            ActionButton(
                title: "Privacy Policy",
                icon: "hand.raised.fill",
                color: .green
            ) {
                openPrivacyPolicy()
            }
            
            ActionButton(
                title: "Help & Support",
                icon: "questionmark.circle.fill",
                color: .orange
            ) {
                openSupport()
            }
            
            ActionButton(
                title: "Sign Out",
                icon: "arrow.right.square",
                color: .red
            ) {
                showingLogoutAlert = true
            }
            
            // Account Deletion Button
            Button(action: {
                showingDeleteAccountAlert = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .frame(width: 24)
                    
                    Text("Delete Account")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.8, green: 0.1, blue: 0.1)) // Dark red
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Computed Properties
    private var currentProfile: UserProfile? {
        appState.supabaseService.currentProfile
    }
    
    private var currentUserRole: UserRole? {
        currentProfile?.role ?? appState.userRole
    }
    
    private var displayName: String {
        currentProfile?.name ?? "Unknown User"
    }
    
    private var currentEmail: String {
        currentProfile?.email ?? appState.supabaseService.currentUser?.email ?? "No email"
    }
    
    private var initials: String {
        let name = displayName
        let components = name.components(separatedBy: " ")
        return components.compactMap { $0.first }.prefix(2).map(String.init).joined()
    }
    
    private var memberSinceText: String {
        guard let createdAt = currentProfile?.createdAt else {
            return "Recently"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: createdAt)
    }
    
    // MARK: - Helper Methods
    private func loadProfile() {
        guard currentProfile != nil else {
            // If no profile is loaded, try to fetch it
            if let userId = appState.supabaseService.currentUser?.id {
                isLoadingProfile = true
                Task {
                    do {
                        _ = try await appState.supabaseService.fetchUserProfile(userId: userId)
                        await MainActor.run {
                            updateEditableFields()
                            isLoadingProfile = false
                        }
                    } catch {
                        await MainActor.run {
                            appState.showError("Failed to load profile: \(error.localizedDescription)")
                            isLoadingProfile = false
                        }
                    }
                }
            }
            return
        }
        
        // Update editable fields with current profile data
        updateEditableFields()
    }
    
    private func updateEditableFields() {
        Task { @MainActor in
            guard let profile = currentProfile else { return }
            editableName = profile.name
            editablePhone = profile.phone ?? ""
            editableLocation = profile.location ?? ""
            editableBio = profile.bio ?? ""
        }
    }
    
    private func startEditing() {
        updateEditableFields()
        withAnimation(.easeInOut(duration: 0.3)) {
            isEditing = true
        }
    }
    
    private func saveProfile() {
        guard let currentProfile = currentProfile else { return }
        
        let updatedProfile = UserProfile(
            id: currentProfile.id,
            email: currentProfile.email,
            name: editableName.trimmingCharacters(in: .whitespaces),
            phone: editablePhone.isEmpty ? nil : editablePhone.trimmingCharacters(in: .whitespaces),
            location: editableLocation.isEmpty ? nil : editableLocation.trimmingCharacters(in: .whitespaces),
            bio: editableBio.isEmpty ? nil : editableBio.trimmingCharacters(in: .whitespaces),
            role: currentProfile.role,
            avatarUrl: currentProfile.avatarUrl,
            isActive: currentProfile.isActive,
            createdAt: currentProfile.createdAt,
            updatedAt: Date()
        )
        
        isUpdatingProfile = true
        
        Task {
            do {
                try await appState.supabaseService.updateUserProfile(updatedProfile)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isEditing = false
                    }
                    isUpdatingProfile = false
                }
            } catch {
                await MainActor.run {
                    appState.showError("Failed to update profile: \(error.localizedDescription)")
                    isUpdatingProfile = false
                }
            }
        }
    }
    
    private func signOut() {
        Task {
            do {
                try await appState.supabaseService.signOut()
                await MainActor.run {
                    appState.logout()
                }
            } catch {
                await MainActor.run {
                    appState.showError("Failed to sign out: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func deleteAccount() {
        isDeletingAccount = true
        Task {
            do {
                try await appState.supabaseService.deleteAccount()
                await MainActor.run {
                    isDeletingAccount = false
                    showingDeleteConfirmation = false
                    deleteConfirmationText = ""
                    showingAccountDeletedAlert = true
                }
            } catch {
                await MainActor.run {
                    appState.showError("Failed to delete account: \(error.localizedDescription)")
                    isDeletingAccount = false
                }
            }
        }
    }
    
    private func getActivityStats() -> [ActivityStat] {
        switch currentUserRole {
        case .parent:
            return [
                ActivityStat(title: "Documents Uploaded", value: "12", icon: "doc.fill", color: .blue),
                ActivityStat(title: "Analyses Created", value: "8", icon: "chart.bar.fill", color: .green),
                ActivityStat(title: "Questions Asked", value: "45", icon: "questionmark.circle.fill", color: .orange),
                ActivityStat(title: "Days Active", value: "23", icon: "calendar.fill", color: .purple)
            ]
        case .teacher:
            return [
                ActivityStat(title: "Students", value: "24", icon: "person.2.fill", color: .blue),
                ActivityStat(title: "IEPs Reviewed", value: "18", icon: "doc.text.fill", color: .green),
                ActivityStat(title: "Reports Generated", value: "6", icon: "chart.pie.fill", color: .orange),
                ActivityStat(title: "Collaborations", value: "12", icon: "person.3.fill", color: .purple)
            ]
        case .counselor:
            return [
                ActivityStat(title: "Assessments", value: "15", icon: "clipboard.fill", color: .blue),
                ActivityStat(title: "Recommendations", value: "32", icon: "lightbulb.fill", color: .green),
                ActivityStat(title: "Follow-ups", value: "28", icon: "arrow.clockwise", color: .orange),
                ActivityStat(title: "Resources Shared", value: "41", icon: "book.fill", color: .purple)
            ]
        case .none:
            return []
        }
    }
    
    private func exportUserData() {
        // TODO: Implement data export functionality
        print("Exporting user data...")
    }
    
    private func openPrivacyPolicy() {
        // TODO: Implement privacy policy
        print("Opening privacy policy...")
    }
    
    private func openSupport() {
        // TODO: Implement support
        print("Opening support...")
    }
}

// MARK: - Delete Account Confirmation View
struct DeleteAccountConfirmationView: View {
    @Binding var deleteConfirmationText: String
    @Binding var isDeletingAccount: Bool
    let onCancel: () -> Void
    let onDelete: () -> Void
    
    private var isDeleteEnabled: Bool {
        deleteConfirmationText == "DELETE"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                warningSection
                confirmationSection
                Spacer()
                buttonSection
            }
            .navigationTitle("Confirm Deletion")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(isDeletingAccount)
        }
    }
    
    private var warningSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
                .padding(.top, 20)
            
            Text("Delete Account")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("This action is irreversible and cannot be recovered. All your data will be permanently deleted.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var confirmationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Type 'DELETE' to confirm:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField("DELETE", text: $deleteConfirmationText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.allCharacters)
                .disableAutocorrection(true)
        }
        .padding(.horizontal)
    }
    
    private var buttonSection: some View {
        VStack(spacing: 12) {
            deleteButton
            cancelButton
        }
        .padding(.bottom, 20)
    }
    
    private var deleteButton: some View {
        Button(action: onDelete) {
            HStack {
                if isDeletingAccount {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    Text("Deleting...")
                } else {
                    Text("Delete my account permanently")
                }
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDeleteEnabled ? Color.red : Color.gray)
            )
        }
        .disabled(!isDeleteEnabled || isDeletingAccount)
        .padding(.horizontal)
    }
    
    private var cancelButton: some View {
        Button("Cancel", action: onCancel)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.blue)
            .disabled(isDeletingAccount)
    }
}

// MARK: - Supporting Views (unchanged)
struct ProfileField: View {
    let icon: String
    let label: String
    @Binding var value: String
    let isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(ColorTheme.primary)
                    .frame(width: 20)
                
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            if isEditing {
                if label == "Bio" {
                    TextEditor(text: $value)
                        .frame(minHeight: 60)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                } else {
                    TextField(label, text: $value)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            } else {
                Text(value.isEmpty ? "Not provided" : value)
                    .font(.subheadline)
                    .foregroundColor(value.isEmpty ? .secondary : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: label == "Bio" ? 60 : 40)
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(8)
            }
        }
    }
}

struct PreferenceToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: ColorTheme.primary))
        }
        .padding(.vertical, 4)
    }
}

struct ActivityStatCard: View {
    let stat: ActivityStat
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: stat.icon)
                .font(.title2)
                .foregroundColor(stat.color)
            
            Text(stat.value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(stat.title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Activity Stat Model
struct ActivityStat {
    let title: String
    let value: String
    let icon: String
    let color: Color
}

// MARK: - Role Change Sheet
struct RoleChangeSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                headerSection
                roleListSection
            }
            .padding()
            .navigationTitle("Change Role")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        Text("Select your role to customize your experience")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.top)
    }
    
    private var roleListSection: some View {
        VStack(spacing: 16) {
            ForEach(UserRole.allCases, id: \.self) { role in
                roleButton(for: role)
            }
        }
    }
    
    private func roleButton(for role: UserRole) -> some View {
        Button(action: {
            // TODO: Implement role change
            dismiss()
        }) {
            HStack {
                Image(systemName: role.icon)
                    .foregroundColor(role.color)
                    .frame(width: 30)
                
                VStack(alignment: .leading) {
                    Text(role.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(getRoleDescription(role))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getRoleDescription(_ role: UserRole) -> String {
        switch role {
        case .parent:
            return "Track your child's progress and collaborate with educators"
        case .teacher:
            return "Manage IEPs and coordinate with families and specialists"
        case .counselor:
            return "Provide assessments and support educational planning"
        }
    }
}
