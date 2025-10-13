//
//  ContentView.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if shouldShowSidebar {
                // iPad: Use NavigationSplitView with sidebar
                iPadNavigationView()
            } else if shouldUseTabBar {
                // iPhone: Use TabView for logged-in screens
                iPhoneNavigationView()
            } else {
                // Full-screen view for landing, role selection, login (both iPhone & iPad)
                fullScreenView()
            }
        }
        .accentColor(.orange)
        // Global error handling
        .alert("Error", isPresented: $appState.showingErrorAlert) {
            Button("OK") {
                appState.clearError()
            }
        } message: {
            Text(appState.errorMessage ?? "An unexpected error occurred")
        }
    }
    
    // MARK: - Computed Properties
    private var shouldShowSidebar: Bool {
        return appState.shouldUseSidebar
    }
    
    private var shouldUseTabBar: Bool {
        return appState.shouldUseTabBar
    }
    
    // MARK: - iPad Navigation (Sidebar)
    @ViewBuilder
    private func iPadNavigationView() -> some View {
        NavigationSplitView {
            List {
                Button(action: { appState.navigate(to: .dashboard) }) {
                    Label("Dashboard", systemImage: "house.fill")
                        .foregroundColor(appState.currentScreen == .dashboard ? .orange : .primary)
                }
                
                Button(action: { appState.navigateToUpload() }) {
                    Label("Upload", systemImage: "plus.circle.fill")
                        .foregroundColor(appState.currentScreen == .upload ? .orange : .primary)
                }
                
                Button(action: { appState.navigateToAnalysis() }) {
                    Label("Analysis", systemImage: "chart.bar.fill")
                        .foregroundColor(appState.currentScreen == .analysis ? .orange : .primary)
                }
                
                Button(action: { appState.navigateToChat() }) {
                    Label("Q&A", systemImage: "message.fill")
                        .foregroundColor(appState.currentScreen == .qa ? .orange : .primary)
                }
                
                Divider()
                
                Button(action: { appState.navigate(to: .profile) }) {
                    Label("Profile", systemImage: "person.fill")
                        .foregroundColor(appState.currentScreen == .profile ? .orange : .primary)
                }
            }
            .navigationTitle("Autism Advisor")
            .accentColor(.orange)
        } detail: {
            mainContentView()
        }
    }
    
    // MARK: - iPhone Navigation (TabView)
    @ViewBuilder
    private func iPhoneNavigationView() -> some View {
        TabView(selection: .constant(appState.currentScreen)) {
            NavigationStack {
                DashboardScreen()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Dashboard")
            }
            .tag(AppState.Screen.dashboard)
            .badge(shouldShowUploadStatus ? "•" : nil)
            
            NavigationStack {
                UploadScreen()
            }
            .tabItem {
                Image(systemName: appState.uploadSession != nil ? "arrow.up.circle.fill" : "plus.circle.fill")
                Text("Upload")
            }
            .tag(AppState.Screen.upload)
            .badge(uploadBadgeText())
            
            NavigationStack {
                AnalysisScreen()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Analysis")
            }
            .tag(AppState.Screen.analysis)
            .badge(appState.hasActiveDocument ? "•" : nil)
            
            NavigationStack {
                QAScreen()
            }
            .tabItem {
                Image(systemName: appState.isChatActive ? "message.fill" : "message")
                Text("Q&A")
            }
            .tag(AppState.Screen.qa)
            .badge(appState.chatMessageCount > 0 ? "\(appState.chatMessageCount)" : nil)
            
            NavigationStack {
                ProfileScreen()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(AppState.Screen.profile)
        }
        .accentColor(.orange)
    }
    
    // MARK: - Full Screen Views (Landing, Role Selection, Login)
    @ViewBuilder
    private func fullScreenView() -> some View {
        NavigationStack {
            mainContentView()
                .navigationBarHidden(true)
        }
    }
    
    // MARK: - Main Content Router
    @ViewBuilder
    private func mainContentView() -> some View {
        switch appState.currentScreen {
        case .landing:
            LandingScreen()
        case .roleSelection:
            RoleSelectionScreen()
        case .login:
            LoginScreen()  // NEW: Added LoginScreen
        case .signup:
            LoginScreen()  // Uses same screen with different mode
        case .dashboard:
            DashboardScreen()
        case .upload:
            UploadScreen()
        case .analysis:
            AnalysisScreen()
        case .qa:
            QAScreen()
        case .profile:
            ProfileScreen()
        }
    }
    
    // MARK: - Helper Properties
    private var shouldShowUploadStatus: Bool {
        return appState.uploadSession != nil && appState.currentScreen != .upload
    }
    
    private var shouldShowChatStatus: Bool {
        return appState.isChatActive && appState.currentScreen != .qa
    }
    
    private func uploadBadgeText() -> String? {
        guard let session = appState.uploadSession else { return nil }
        
        switch session.status {
        case .completed: return "✓"
        case .failed: return "!"
        default: return nil
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Landing Screen Preview
            ContentView()
                .environmentObject({
                    let state = AppState()
                    state.currentScreen = .landing
                    return state
                }())
                .previewDisplayName("Landing")
            
            // Role Selection Preview
            ContentView()
                .environmentObject({
                    let state = AppState()
                    state.currentScreen = .roleSelection
                    return state
                }())
                .previewDisplayName("Role Selection")
            
            // Login Screen Preview
            ContentView()
                .environmentObject({
                    let state = AppState()
                    state.currentScreen = .login
                    state.userRole = .teacher
                    return state
                }())
                .previewDisplayName("Login")
            
            // Dashboard Preview
            ContentView()
                .environmentObject({
                    let state = AppState()
                    state.currentScreen = .dashboard
                    state.isLoggedIn = true
                    state.userRole = .teacher
                    return state
                }())
                .previewDisplayName("Dashboard")
        }
    }
}
