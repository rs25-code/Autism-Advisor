//
//  LandingScreen.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI
import AVKit
import AVFoundation

struct LandingScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var showAppName = false
    @State private var showRoles = false
    @State private var player: AVPlayer?
    @State private var videoLoaded = false
    @State private var videoHasPlayed = false // FIXED: Track if video has played
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Name with responsive sizing
                VStack(spacing: 8) {
                    Text("IEP Advisor")
                        .font(.system(size: appState.isPad ? 64 : 48, weight: .black, design: .default))
                        .foregroundColor(.white)
                        .opacity(showAppName ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 1.5).delay(0.5), value: showAppName)
                    
                    Text("AI-Powered IEP and 504 Analysis")
                        .font(appState.isPad ? .title2 : .headline)
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(showAppName ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 1.5).delay(1.0), value: showAppName)
                }
                
                // Simplified Video Section
                VStack {
                    if let player = player, videoLoaded {
                        // Use the simple VideoPlayer from AVKit but with minimal configuration
                        VideoPlayer(player: player)
                            .frame(
                                width: appState.isPad ? 600 : min(UIScreen.main.bounds.width - 40, 400),
                                height: appState.isPad ? 400 : min((UIScreen.main.bounds.width - 40) * 0.6, 240)
                            )
                            .cornerRadius(16)
                            .shadow(radius: 10)
                            .disabled(true) // Disable user interaction
                            .onAppear {
                                // FIXED: Only play if hasn't played yet
                                if !videoHasPlayed {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        player.play()
                                        videoHasPlayed = true
                                    }
                                }
                            }
                    } else {
                        // Placeholder while video loads
                        ZStack {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(
                                    width: appState.isPad ? 600 : min(UIScreen.main.bounds.width - 40, 400),
                                    height: appState.isPad ? 400 : min((UIScreen.main.bounds.width - 40) * 0.6, 240)
                                )
                                .cornerRadius(16)
                            
                            if player == nil {
                                VStack(spacing: 12) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("Introduction Video")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text("Loading...")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            } else {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                            }
                        }
                    }
                }
                
                // Role Selection - Responsive Layout
                VStack(spacing: 16) {
                    Text("Choose your role to get started")
                        .font(appState.isPad ? .title3 : .headline)
                        .foregroundColor(.white)
                        .opacity(showRoles ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 1.0), value: showRoles)
                    
                    if appState.isPad {
                        // iPad: Horizontal layout
                        HStack(spacing: 20) {
                            ForEach(Array(UserRole.allCases.enumerated()), id: \.element) { index, role in
                                RoleCard(role: role) {
                                    selectRole(role)
                                }
                                .opacity(showRoles ? 1.0 : 0.0)
                                .offset(y: showRoles ? 0 : 30)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.2),
                                    value: showRoles
                                )
                            }
                        }
                    } else {
                        // iPhone: Vertical layout
                        VStack(spacing: 12) {
                            ForEach(Array(UserRole.allCases.enumerated()), id: \.element) { index, role in
                                CompactRoleCard(role: role) {
                                    selectRole(role)
                                }
                                .opacity(showRoles ? 1.0 : 0.0)
                                .offset(x: showRoles ? 0 : -30)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.15),
                                    value: showRoles
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Footer
                VStack(spacing: 8) {
                    Text("Empowering educators, parents, and counselors")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .opacity(showRoles ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 1.0).delay(1.0), value: showRoles)
                    
                    HStack(spacing: 20) {
                        Button("Privacy Policy") {
                            // Handle privacy policy
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                        
                        Button("Terms of Service") {
                            // Handle terms
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                    }
                    .opacity(showRoles ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0).delay(1.2), value: showRoles)
                }
                .padding(.bottom, appState.isPhone ? 20 : 40)
            }
        }
        .onAppear {
            setupVideo()
            // Check for existing session when landing screen appears
                Task {
                    await appState.checkForExistingSession()
                }
        }
        .onDisappear {
            cleanupVideo()
        }
    }
    
    // MARK: - Helper Methods
    private func selectRole(_ role: UserRole) {
        // Navigate to role selection screen instead of directly logging in
        appState.navigate(to: .roleSelection)
    }
    
    private func setupVideo() {
        // Configure logging to reduce console noise
        configureLogging()
        
        // Start animations immediately
        startAnimationSequence()
        
        // Try to setup video in background
        Task {
            await setupVideoPlayer()
        }
    }
    
    private func configureLogging() {
        // Suppress system-level video analysis logs in debug builds
        #if DEBUG
        // Reduce Core Audio logging
        setenv("CA_ASSERT_QUEUE", "0", 1)
        setenv("CA_DEBUG_LOGGING", "0", 1)
        
        // Suppress Media Analysis Daemon logs
        setenv("MAD_DISABLE_LOGGING", "1", 1)
        #endif
    }
    
    private func setupVideoPlayer() async {
        // Check if video file exists
        guard let videoURL = Bundle.main.url(forResource: "intro_video", withExtension: "mp4") else {
            print("❌ Video file 'intro_video.mp4' not found in Resources")
            return
        }
        
        print("✅ Found video file at: \(videoURL)")
        
        await MainActor.run {
            // Create asset with minimal options to reduce system calls
            let asset = AVURLAsset(url: videoURL, options: [
                AVURLAssetPreferPreciseDurationAndTimingKey: false, // Reduces analysis overhead
                AVURLAssetHTTPUserAgentKey: "AutismApp/1.0"
            ])
            
            let playerItem = AVPlayerItem(asset: asset)
            let newPlayer = AVPlayer(playerItem: playerItem)
            
            // Configure for minimal system interference
            newPlayer.isMuted = true
            newPlayer.allowsExternalPlayback = false
            newPlayer.preventsDisplaySleepDuringVideoPlayback = false
            newPlayer.actionAtItemEnd = .pause // FIXED: Set to pause instead of none
            
            // Reduce buffer requirements to minimize resource usage
            playerItem.preferredForwardBufferDuration = 2.0
            
            self.player = newPlayer
            
            // Simple status observation with error suppression
            playerItem.publisher(for: \.status)
                .receive(on: DispatchQueue.main)
                .sink { status in
                    switch status {
                    case .readyToPlay:
                        print("✅ Video ready to play")
                        self.videoLoaded = true
                    case .failed:
                        if let error = playerItem.error {
                            print("❌ Video failed to load: \(error.localizedDescription)")
                        }
                    case .unknown:
                        // Suppress unknown status logs to reduce console noise
                        break
                    @unknown default:
                        break
                    }
                }
                .store(in: &cancellables)
            
            // FIXED: Remove the loop notification - video will just end naturally
            // No more AVPlayerItemDidPlayToEndTime notification handling
        }
    }
    
    @State private var cancellables = Set<AnyCancellable>()
    
    private func startAnimationSequence() {
        // Start app name animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 1.5)) {
                showAppName = true
            }
        }
        
        // Start roles animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                showRoles = true
            }
        }
    }
    
    private func cleanupVideo() {
        player?.pause()
        player = nil
        cancellables.removeAll()
        NotificationCenter.default.removeObserver(self)
        // FIXED: Reset video played state when view disappears
        videoHasPlayed = false
        videoLoaded = false
    }
}

// MARK: - Role Cards (same as before)
struct RoleCard: View {
    let role: UserRole
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: role.icon)
                    .font(.system(size: 32))
                    .foregroundColor(role.color)
                    .frame(width: 64, height: 64)
                    .background(role.color.opacity(0.1))
                    .cornerRadius(32)
                
                VStack(spacing: 8) {
                    Text(role.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(roleDescription(for: role))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .padding()
            .frame(width: 180, height: 200)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func roleDescription(for role: UserRole) -> String {
        switch role {
        case .parent:
            return "Access your child's IEP analysis, track progress, and communicate with educators"
        case .teacher:
            return "Analyze student IEPs, create implementation plans, and collaborate with teams"
        case .counselor:
            return "Provide guidance, coordinate services, and support student success"
        }
    }
}

struct CompactRoleCard: View {
    let role: UserRole
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: role.icon)
                    .font(.title2)
                    .foregroundColor(role.color)
                    .frame(width: 48, height: 48)
                    .background(role.color.opacity(0.1))
                    .cornerRadius(24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(role.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(compactDescription(for: role))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func compactDescription(for role: UserRole) -> String {
        switch role {
        case .parent:
            return "Track progress & collaborate"
        case .teacher:
            return "Analyze & implement IEPs"
        case .counselor:
            return "Coordinate & support"
        }
    }
}

// MARK: - Combine Import
import Combine

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
