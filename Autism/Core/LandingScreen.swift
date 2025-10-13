//
//  LandingScreen.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI

struct LandingScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var hasNavigated = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image - properly sized for both iPhone and iPad
                if let image = UIImage(named: "landing-image") {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .ignoresSafeArea()
                } else {
                    // Fallback gradient background if image not found
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            // Only proceed if we haven't already navigated
            guard !hasNavigated else { return }
            
            // Check for existing session first
            Task {
                await checkSessionAndNavigate()
            }
        }
    }
    
    @MainActor
    private func checkSessionAndNavigate() async {
        // Check if user has an existing session
        await appState.checkForExistingSession()
        
        // Only proceed with automatic navigation if we haven't been redirected already
        guard !hasNavigated && appState.currentScreen == .landing else {
            return
        }
        
        // Wait for 2 seconds as requested, then navigate to role selection
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Double-check we're still on landing screen and haven't navigated
        guard !hasNavigated && appState.currentScreen == .landing else {
            return
        }
        
        hasNavigated = true
        withAnimation(.easeInOut(duration: 0.5)) {
            appState.navigate(to: .roleSelection)
        }
    }
}

// MARK: - Preview
struct LandingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LandingScreen()
                .environmentObject(AppState())
                .previewDevice("iPhone 14 Pro")
                .previewDisplayName("iPhone")
            
            LandingScreen()
                .environmentObject(AppState())
                .previewDevice("iPad Pro (12.9-inch)")
                .previewDisplayName("iPad")
        }
    }
}
