//
//  LoginScreen.swift
//  Autism
//
//  Created by Rhea Sreedhar on 9/9/25.
//

import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var appState: AppState
    
    // Form state
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var isSignUpMode = false
    @State private var showingPassword = false
    
    // UI state
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        headerSection
                        
                        // Form Section
                        VStack(spacing: 24) {
                            // Role Display
                            selectedRoleSection
                            
                            // Auth Form
                            authFormSection
                            
                            // Submit Button
                            submitButtonSection
                            
                            // Toggle Auth Mode
                            toggleModeSection
                            
                            // Back to Role Selection
                            backButtonSection
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 32)
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .alert("Authentication Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onReceive(appState.supabaseService.$errorMessage) { error in
            if let error = error {
                errorMessage = error
                showingError = true
            }
        }
        .onReceive(appState.supabaseService.$isLoading) { loading in
            isLoading = loading
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            // App Icon
            Circle()
                .fill(Color.orange.opacity(0.1))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 44))
                        .foregroundColor(.orange)
                )
            
            // Title
            VStack(spacing: 8) {
                Text(isSignUpMode ? "Create Account" : "Welcome Back")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(isSignUpMode ? "Join our community of educators and parents" : "Sign in to continue your journey")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 40)
        .padding(.bottom, 20)
    }
    
    // MARK: - Selected Role Section
    private var selectedRoleSection: some View {
        Group {
            if let role = appState.userRole {
                HStack(spacing: 12) {
                    Image(systemName: role.icon)
                        .font(.title3)
                        .foregroundColor(role.color)
                        .frame(width: 32, height: 32)
                        .background(role.color.opacity(0.1))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Continuing as")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(role.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Button("Change") {
                        appState.navigate(to: .roleSelection)
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6).opacity(0.5))
                )
            }
        }
    }
    
    // MARK: - Auth Form Section
    private var authFormSection: some View {
        VStack(spacing: 16) {
            // Full Name (Sign Up Only)
            if isSignUpMode {
                CustomTextField(
                    title: "Full Name",
                    text: $fullName,
                    placeholder: "Enter your full name",
                    icon: "person.fill"
                )
                .textContentType(.name)
                .autocapitalization(.words)
            }
            
            // Email Field
            CustomTextField(
                title: "Email",
                text: $email,
                placeholder: "Enter your email address",
                icon: "envelope.fill"
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .autocorrectionDisabled()
            
            // Password Field
            CustomSecureField(
                title: "Password",
                text: $password,
                placeholder: "Enter your password",
                icon: "lock.fill",
                isSecure: !showingPassword,
                toggleAction: { showingPassword.toggle() }
            )
            .textContentType(isSignUpMode ? .newPassword : .password)
            
            // Password Requirements (Sign Up Only)
            if isSignUpMode {
                PasswordRequirements(password: password)
            }
        }
    }
    
    // MARK: - Submit Button Section
    private var submitButtonSection: some View {
        VStack(spacing: 12) {
            Button(action: submitForm) {
                HStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text(isSignUpMode ? "Create Account" : "Sign In")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isFormValid ? Color.orange : Color(.systemGray4))
                )
                .foregroundColor(isFormValid ? .white : .secondary)
            }
            .disabled(!isFormValid || isLoading)
            .animation(.easeInOut(duration: 0.2), value: isFormValid)
            
            if !isSignUpMode {
                Button("Forgot Password?") {
                    // Handle forgot password
                    handleForgotPassword()
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }
        }
    }
    
    // MARK: - Toggle Mode Section
    private var toggleModeSection: some View {
        HStack(spacing: 4) {
            Text(isSignUpMode ? "Already have an account?" : "Don't have an account?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(isSignUpMode ? "Sign In" : "Sign Up") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSignUpMode.toggle()
                    clearForm()
                }
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.orange)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Back Button Section
    private var backButtonSection: some View {
        Button("Back to Role Selection") {
            appState.navigate(to: .roleSelection)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
        .padding(.top, 20)
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        let emailValid = !email.isEmpty && email.contains("@")
        let passwordValid = password.count >= 6
        let nameValid = !isSignUpMode || !fullName.trimmingCharacters(in: .whitespaces).isEmpty
        
        return emailValid && passwordValid && nameValid
    }
    
    // MARK: - Helper Methods
    private func submitForm() {
        guard isFormValid else { return }
        
        Task {
            if isSignUpMode {
                await appState.signUp(
                    email: email.trimmingCharacters(in: .whitespaces),
                    password: password,
                    fullName: fullName.trimmingCharacters(in: .whitespaces)
                )
            } else {
                await appState.signIn(
                    email: email.trimmingCharacters(in: .whitespaces),
                    password: password
                )
            }
        }
    }
    
    private func handleForgotPassword() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address first"
            showingError = true
            return
        }
        
        Task {
            do {
                try await appState.supabaseService.resetPassword(email: email)
                errorMessage = "Password reset email sent! Check your inbox."
                showingError = true
            } catch {
                errorMessage = "Failed to send reset email: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        fullName = ""
        showingPassword = false
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .font(.subheadline)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: text.isEmpty ? 0 : 1)
                    )
            )
        }
    }
}

// MARK: - Custom Secure Field
struct CustomSecureField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    let isSecure: Bool
    let toggleAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(.subheadline)
                
                Button(action: toggleAction) {
                    Image(systemName: isSecure ? "eye" : "eye.slash")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: text.isEmpty ? 0 : 1)
                    )
            )
        }
    }
}

// MARK: - Password Requirements
struct PasswordRequirements: View {
    let password: String
    
    private var requirements: [(String, Bool)] {
        [
            ("At least 6 characters", password.count >= 6),
            ("Contains a letter", password.rangeOfCharacter(from: .letters) != nil),
            ("Contains a number", password.rangeOfCharacter(from: .decimalDigits) != nil)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Password Requirements:")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            ForEach(Array(requirements.enumerated()), id: \.offset) { _, requirement in
                HStack(spacing: 8) {
                    Image(systemName: requirement.1 ? "checkmark.circle.fill" : "circle")
                        .font(.caption2)
                        .foregroundColor(requirement.1 ? .green : .secondary)
                    
                    Text(requirement.0)
                        .font(.caption2)
                        .foregroundColor(requirement.1 ? .primary : .secondary)
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Preview
struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
            .environmentObject({
                let state = AppState()
                state.userRole = .teacher
                return state
            }())
    }
}
