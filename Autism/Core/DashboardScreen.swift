//
//  DashboardScreen.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI

struct DashboardScreen: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Content
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Section
                    welcomeSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Recent Documents
                    recentDocumentsSection
                    
                    // Role-Specific Section
                    roleSpecificSection
                }
                .padding(.horizontal, appState.isPad ? 32 : 20)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Profile
                    Button(action: { appState.navigate(to: .profile) }) {
                        if let role = appState.userRole {
                            Image(systemName: role.icon)
                                .font(.title3)
                                .foregroundColor(role.color)
                        } else {
                            Image(systemName: "person.circle")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let role = appState.userRole {
                        Text("Continue your work as a \(role.displayName.lowercased())")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let role = appState.userRole {
                    Image(systemName: role.icon)
                        .font(.system(size: 40))
                        .foregroundColor(role.color)
                        .frame(width: 60, height: 60)
                        .background(role.color.opacity(0.1))
                        .cornerRadius(30)
                }
            }
            
            // Stats based on actual data
            statsCards
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Stats Cards
    private var statsCards: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Documents",
                value: "\(appState.documentHistory.count)",
                icon: "doc.text.fill",
                color: .blue
            )
            
            StatCard(
                title: "Active",
                value: appState.currentIEP != nil ? "1" : "0",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            StatCard(
                title: "Chat",
                value: appState.chatSession != nil ? "Active" : "None",
                icon: "message.fill",
                color: .orange
            )
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                QuickActionCard(
                    title: "Upload Document",
                    subtitle: "Analyze a new IEP or 504 plan",
                    icon: "plus.circle.fill",
                    color: .blue
                ) {
                    appState.navigate(to: .upload)
                }
                
                if appState.hasActiveDocument {
                    QuickActionCard(
                        title: "Continue Analysis",
                        subtitle: "View current document insights",
                        icon: "chart.bar.fill",
                        color: .green
                    ) {
                        appState.navigate(to: .analysis)
                    }
                    
                    QuickActionCard(
                        title: "Ask Questions",
                        subtitle: "Chat about your document",
                        icon: "message.fill",
                        color: .orange
                    ) {
                        appState.navigateToChat()
                    }
                }
            }
        }
    }
    
    // MARK: - Recent Documents Section
    private var recentDocumentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Documents")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if appState.hasDocumentHistory {
                    Button("View All") {
                        appState.navigate(to: .analysis)
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                }
            }
            
            if appState.hasDocumentHistory {
                VStack(spacing: 12) {
                    ForEach(appState.documentHistory.prefix(3)) { document in
                        DocumentRow(document: document) {
                            appState.currentIEP = document
                            appState.navigate(to: .analysis)
                        }
                    }
                }
            } else {
                EmptyDocumentsView()
            }
        }
    }
    
    // MARK: - Role Specific Section
    private var roleSpecificSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(getRoleSpecificTitle())
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(getRoleSpecificActions(), id: \.title) { action in
                    RoleActionCard(action: action)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getRoleSpecificTitle() -> String {
        switch appState.userRole {
        case .parent: return "Parent Resources"
        case .teacher: return "Teaching Tools"
        case .counselor: return "Counseling Resources"
        case .none: return "Getting Started"
        }
    }
    
    private func getRoleSpecificActions() -> [RoleAction] {
        switch appState.userRole {
        case .parent:
            return [
                RoleAction(title: "Understanding IEPs", subtitle: "Learn about your child's plan", icon: "book.fill", action: {}),
                RoleAction(title: "Home Strategies", subtitle: "Support learning at home", icon: "house.fill", action: {}),
                RoleAction(title: "Team Communication", subtitle: "Connect with educators", icon: "message.fill", action: {})
            ]
        case .teacher:
            return [
                RoleAction(title: "Implementation Guide", subtitle: "Best practices for IEP goals", icon: "graduationcap.fill", action: {}),
                RoleAction(title: "Progress Tracking", subtitle: "Monitor student development", icon: "chart.line.uptrend.xyaxis", action: {}),
                RoleAction(title: "Collaboration Tools", subtitle: "Work with the IEP team", icon: "person.3.fill", action: {})
            ]
        case .counselor:
            return [
                RoleAction(title: "Assessment Tools", subtitle: "Evaluation resources", icon: "checkmark.seal.fill", action: {}),
                RoleAction(title: "Service Coordination", subtitle: "Manage student services", icon: "arrow.triangle.branch", action: {}),
                RoleAction(title: "Meeting Support", subtitle: "Facilitate IEP meetings", icon: "calendar.badge.plus", action: {})
            ]
        case .none:
            return []
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(20)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DocumentRow: View {
    let document: IEPData
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Document icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.blue)
                }
                
                // Document info
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.studentName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Uploaded \(timeAgo(document.uploadDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.3))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyDocumentsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Documents Yet")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Upload your first IEP or 504 plan to get started with AI-powered analysis")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.3))
        )
    }
}

struct RoleActionCard: View {
    let action: RoleAction
    
    var body: some View {
        Button(action: action.action) {
            HStack(spacing: 12) {
                Image(systemName: action.icon)
                    .font(.title3)
                    .foregroundColor(.orange)
                    .frame(width: 32, height: 32)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(action.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(action.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.3))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Types

struct RoleAction {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
}

// MARK: - Preview

struct DashboardScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Empty state
            DashboardScreen()
                .environmentObject({
                    let state = AppState()
                    state.userRole = .teacher
                    state.isLoggedIn = true
                    return state
                }())
                .previewDisplayName("Empty Dashboard")
            
            // With documents
            DashboardScreen()
                .environmentObject({
                    let state = AppState()
                    state.userRole = .parent
                    state.isLoggedIn = true
                    // Would have real documents from Supabase
                    return state
                }())
                .previewDisplayName("With Documents")
        }
    }
}
