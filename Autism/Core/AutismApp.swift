//
//  AutismApp.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI

@main
struct AutismApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    setupAppearance()
                }
        }
    }
    
    private func setupAppearance() {
        // Configure global app appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Set accent color globally
        UIView.appearance().tintColor = UIColor.themePrimary
    }
}
