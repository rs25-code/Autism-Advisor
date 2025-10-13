//
//  RoleSelection.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI

struct RoleSelectionScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedRole: UserRole? = nil
    @State private var showingRoleInfo = false
    @State private var infoRole: UserRole? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Content Area
                ScrollView {
                    VStack(spacing: 24) {
                        // Welcome Message
                        welcomeSection
                        
                        // Role Cards
                        roleCardsSection
                        
                        // Continue Button
                        continueButtonSection
                        
                        // Help Section
                        helpSection
                    }
                    .padding(.horizontal, appState.isPad ? 32 : 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Choose Your Role")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { appState.navigate(to: .landing) }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingRoleInfo) {
            if let role = infoRole {
                RoleInfoSheet(role: role)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            // App logo/icon area
            Circle()
                .fill(Color.orange.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 36))
                        .foregroundColor(.orange)
                )
            
            VStack(spacing: 4) {
                Text("Welcome to Autism")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("AI-Powered IEP Analysis")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(spacing: 16) {
            Text("Choose Your Role")
                .font(appState.isPad ? .title : .title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Select the role that best describes you to get personalized features and content tailored to your needs.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
    }
    
    // MARK: - Role Cards Section
    private var roleCardsSection: some View {
        VStack(spacing: 16) {
            ForEach(UserRole.allCases, id: \.self) { role in
                RoleSelectionCard(
                    role: role,
                    isSelected: selectedRole == role,
                    onSelect: { selectRole(role) },
                    onInfo: { showRoleInfo(role) }
                )
                .animation(.easeInOut(duration: 0.2), value: selectedRole)
            }
        }
    }
    
    // MARK: - Continue Button Section
    private var continueButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: continueToLogin) {
                HStack(spacing: 12) {
                    Text("Continue to Login")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
                        .font(.title3)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(selectedRole != nil ? Color.orange : Color(.systemGray4))
                )
                .foregroundColor(selectedRole != nil ? .white : .secondary)
                .scaleEffect(selectedRole != nil ? 1.0 : 0.95)
                .animation(.easeInOut(duration: 0.2), value: selectedRole)
            }
            .disabled(selectedRole == nil)
            
            if selectedRole == nil {
                Text("Please select a role to continue")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .animation(.easeInOut(duration: 0.2), value: selectedRole)
            } else if let role = selectedRole {
                Text("Continue as \(role.displayName)")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
                    .animation(.easeInOut(duration: 0.2), value: selectedRole)
            }
            
            // Demo Mode Button (for testing)
            Button("Continue in Demo Mode") {
                continueToDemo()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.top, 8)
    }
    
    // MARK: - Help Section
    private var helpSection: some View {
        VStack(spacing: 12) {
            Text("Need help choosing?")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("You can change your role anytime in your profile settings. Each role provides different features and perspectives tailored to your specific needs.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
    
    // MARK: - Helper Methods
    private func selectRole(_ role: UserRole) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedRole = role
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func showRoleInfo(_ role: UserRole) {
        infoRole = role
        showingRoleInfo = true
    }
    
    // MARK: - Updated Navigation Methods
    
    private func continueToLogin() {
        guard let role = selectedRole else { return }
        
        // Haptic feedback for success
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Use the new Supabase authentication flow
        appState.proceedToLogin(with: role)
    }
    
    private func continueToDemo() {
        guard let role = selectedRole else { return }
        
        // Haptic feedback for success
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Use the legacy demo login (bypasses Supabase)
        appState.login(as: role)
    }
}

// MARK: - Role Selection Card
struct RoleSelectionCard: View {
    let role: UserRole
    let isSelected: Bool
    let onSelect: () -> Void
    let onInfo: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Role Icon
                ZStack {
                    Circle()
                        .fill(role.color.opacity(isSelected ? 0.2 : 0.1))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(role.color.opacity(isSelected ? 0.6 : 0.3), lineWidth: isSelected ? 3 : 1)
                        )
                    
                    Image(systemName: role.icon)
                        .font(.title2)
                        .foregroundColor(role.color)
                }
                
                // Role Information
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(role.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: onInfo) {
                            Image(systemName: "info.circle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            onInfo()
                        }
                    }
                    
                    Text(getRoleDescription(role))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    
                    // Role Features
                    HStack(spacing: 8) {
                        ForEach(getRoleFeatures(role), id: \.self) { feature in
                            Text(feature)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(role.color.opacity(0.1))
                                .foregroundColor(role.color)
                                .cornerRadius(4)
                        }
                    }
                }
                
                // Selection Indicator
                VStack {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(role.color)
                    } else {
                        Circle()
                            .stroke(Color(.systemGray4), lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }
                    Spacer()
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? role.color.opacity(0.4) : Color(.systemGray5),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? role.color.opacity(0.3) : .black.opacity(0.05),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private func getRoleDescription(_ role: UserRole) -> String {
        switch role {
        case .parent:
            return "Track your child's progress and collaborate with educators"
        case .teacher:
            return "Analyze student IEPs and create implementation plans"
        case .counselor:
            return "Coordinate services and support student success"
        }
    }
    
    private func getRoleFeatures(_ role: UserRole) -> [String] {
        switch role {
        case .parent:
            return ["Progress Tracking", "Home Strategies", "Team Communication"]
        case .teacher:
            return ["IEP Analysis", "Lesson Planning", "Progress Monitoring"]
        case .counselor:
            return ["Case Management", "Service Coordination", "Team Meetings"]
        }
    }
}

// MARK: - Role Info Sheet
struct RoleInfoSheet: View {
    let role: UserRole
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(role.color.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: role.icon)
                                .font(.system(size: 36))
                                .foregroundColor(role.color)
                        }
                        
                        VStack(spacing: 8) {
                            Text(role.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Role Information")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What you'll get:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(getDetailedDescription(role))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Key Features:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            ForEach(getDetailedFeatures(role), id: \.title) { feature in
                                FeatureRow(feature: feature, color: role.color)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Note
                    VStack(spacing: 8) {
                        Text("Note")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("You can change your role anytime in your profile settings. Each role is designed to provide the most relevant tools and insights for your specific needs.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Role Information")
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
    
    private func getDetailedDescription(_ role: UserRole) -> String {
        switch role {
        case .parent:
            return "As a parent, you'll have access to tools specifically designed to help you understand your child's IEP, track their progress, and collaborate effectively with their educational team. Get insights into how to support your child's learning at home and stay informed about their development."
        case .teacher:
            return "As a teacher, you'll have access to comprehensive IEP analysis tools, implementation strategies, and collaboration features. Create data-driven lesson plans, track student progress, and connect with other team members to ensure the best outcomes for your students."
        case .counselor:
            return "As a counselor, you'll have access to assessment tools, service coordination features, and team facilitation resources. Help coordinate services, support student success, and maintain clear communication between all stakeholders in the IEP process."
        }
    }
    
    private func getDetailedFeatures(_ role: UserRole) -> [RoleFeature] {
        switch role {
        case .parent:
            return [
                RoleFeature(title: "Progress Tracking", description: "Monitor your child's goal progress and milestones", icon: "chart.line.uptrend.xyaxis"),
                RoleFeature(title: "Home Strategies", description: "Get personalized tips for supporting learning at home", icon: "house.fill"),
                RoleFeature(title: "Team Communication", description: "Connect and collaborate with your child's educational team", icon: "message.fill"),
                RoleFeature(title: "Document Analysis", description: "Understand IEP documents with AI-powered insights", icon: "doc.text.magnifyingglass")
            ]
        case .teacher:
            return [
                RoleFeature(title: "Lesson Planning", description: "Create IEP-aligned lesson plans and activities", icon: "doc.text.badge.plus"),
                RoleFeature(title: "Progress Monitoring", description: "Track and document student progress efficiently", icon: "chart.bar.xaxis"),
                RoleFeature(title: "Data Analysis", description: "Generate insights from student performance data", icon: "chart.pie.fill"),
                RoleFeature(title: "Collaboration Tools", description: "Work seamlessly with IEP team members", icon: "person.3.fill")
            ]
        case .counselor:
            return [
                RoleFeature(title: "Case Management", description: "Organize and track multiple student cases", icon: "folder.fill"),
                RoleFeature(title: "Assessment Tools", description: "Access evaluation and assessment resources", icon: "checkmark.seal.fill"),
                RoleFeature(title: "Service Coordination", description: "Coordinate services across providers", icon: "arrow.triangle.branch"),
                RoleFeature(title: "Meeting Support", description: "Facilitate and document IEP meetings", icon: "calendar.badge.plus")
            ]
        }
    }
}

// MARK: - Supporting Types
struct RoleFeature {
    let title: String
    let description: String
    let icon: String
}

struct FeatureRow: View {
    let feature: RoleFeature
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: feature.icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}
