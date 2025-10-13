//
//  WaveformView.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI

struct WaveformView: View {
    let audioLevels: [Float]
    let isRecording: Bool
    
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<numberOfBars, id: \.self) { index in
                WaveformBar(
                    height: barHeight(for: index),
                    isRecording: isRecording,
                    animationDelay: Double(index) * 0.1
                )
            }
        }
        .frame(height: 40)
        .animation(.easeInOut(duration: 0.3), value: audioLevels)
    }
    
    // MARK: - Constants
    private let numberOfBars = 25
    private let minBarHeight: CGFloat = 2
    private let maxBarHeight: CGFloat = 40
    
    // MARK: - Helper Methods
    private func barHeight(for index: Int) -> CGFloat {
        guard !audioLevels.isEmpty else {
            return isRecording ? minBarHeight : 0
        }
        
        // Map index to audio levels array
        let levelIndex = min(index, audioLevels.count - 1)
        let level = audioLevels[levelIndex]
        
        // Convert level to bar height
        let height = minBarHeight + CGFloat(level) * (maxBarHeight - minBarHeight)
        return max(minBarHeight, min(maxBarHeight, height))
    }
}

struct WaveformBar: View {
    let height: CGFloat
    let isRecording: Bool
    let animationDelay: Double
    
    @State private var animatedHeight: CGFloat = 2
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(barColor)
            .frame(width: 3, height: animatedHeight)
            .onAppear {
                if isRecording {
                    startAnimation()
                }
            }
            .onChange(of: height) { oldValue, newValue in
                withAnimation(.easeInOut(duration: 0.1)) {
                    animatedHeight = newValue
                }
            }
            .onChange(of: isRecording) { oldValue, newValue in
                if newValue {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
    }
    
    private var barColor: Color {
        if !isRecording {
            return .gray.opacity(0.3)
        }
        
        // Color based on height - more vibrant for higher levels
        let intensity = min(1.0, height / 40.0)
        return Color.orange.opacity(0.3 + intensity * 0.7)
    }
    
    private func startAnimation() {
        isAnimating = true
        
        // Continuous subtle animation while recording
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard isAnimating else {
                timer.invalidate()
                return
            }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                // Add small random variation to create "breathing" effect
                let variation = CGFloat.random(in: -2...2)
                animatedHeight = max(2, height + variation)
            }
        }
    }
    
    private func stopAnimation() {
        isAnimating = false
        withAnimation(.easeOut(duration: 0.5)) {
            animatedHeight = 2
        }
    }
}

// MARK: - Voice Input Button
struct VoiceInputButton: View {
    @ObservedObject var voiceService: VoiceInputService
    let onTranscriptionComplete: (String) -> Void
    
    @State private var showingPermissionAlert = false
    
    var body: some View {
        Button(action: toggleRecording) {
            ZStack {
                Circle()
                    .fill(buttonColor)
                    .frame(width: 44, height: 44)
                    .scaleEffect(voiceService.isRecording ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: voiceService.isRecording)
                
                Image(systemName: buttonIcon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .rotationEffect(.degrees(voiceService.isRecording ? 0 : 0))
            }
        }
        .disabled(voiceService.permissionStatus == .denied)
        .alert("Microphone Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                openSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable microphone access in Settings to use voice input.")
        }
        .alert("Voice Input Error", isPresented: $voiceService.hasError) {
            Button("OK") {
                voiceService.hasError = false
            }
        } message: {
            Text(voiceService.errorMessage)
        }
        .onChange(of: voiceService.transcribedText) { oldValue, newValue in
            // FIXED: Only process transcription when recording stops AND we have text
            if !newValue.isEmpty && !voiceService.isRecording {
                print("🎤 Processing transcription: '\(newValue)'")
                onTranscriptionComplete(newValue)
                voiceService.clearTranscription()
            }
        }
        .onChange(of: voiceService.isRecording) { oldValue, newValue in
            // FIXED: When recording stops, check if we have transcription
            if oldValue && !newValue {
                // Recording just stopped
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if !voiceService.transcribedText.isEmpty {
                        print("🎤 Recording stopped with text: '\(voiceService.transcribedText)'")
                        onTranscriptionComplete(voiceService.transcribedText)
                        voiceService.clearTranscription()
                    }
                }
            }
        }
    }
    
    private var buttonColor: Color {
        if voiceService.isRecording {
            return .red.opacity(0.2)
        } else if voiceService.permissionStatus == .denied {
            return .gray.opacity(0.2)
        } else {
            return .orange.opacity(0.1)
        }
    }
    
    private var iconColor: Color {
        if voiceService.isRecording {
            return .red
        } else if voiceService.permissionStatus == .denied {
            return .gray
        } else {
            return .orange
        }
    }
    
    private var buttonIcon: String {
        if voiceService.isRecording {
            return "stop.circle.fill"
        } else if voiceService.permissionStatus == .denied {
            return "mic.slash.fill"
        } else {
            return "mic.fill"
        }
    }
    
    private func toggleRecording() {
        if voiceService.isRecording {
            voiceService.stopRecording()
        } else {
            Task {
                let hasPermission = await voiceService.requestPermissions()
                if hasPermission {
                    await voiceService.startRecording()
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Voice Recording Overlay
struct VoiceRecordingOverlay: View {
    @ObservedObject var voiceService: VoiceInputService
    let onCancel: () -> Void
    
    var body: some View {
        if voiceService.isRecording {
            ZStack {
                // Semi-transparent background
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        voiceService.stopRecording()
                    }
                
                // Recording indicator card
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        // Recording indicator
                        HStack(spacing: 8) {
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                                .opacity(0.8)
                                .scaleEffect(1.2)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: voiceService.isRecording)
                            
                            Text("Recording...")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        
                        // Waveform
                        WaveformView(
                            audioLevels: voiceService.audioLevels,
                            isRecording: voiceService.isRecording
                        )
                        
                        // Current transcription
                        if !voiceService.transcribedText.isEmpty {
                            ScrollView {
                                Text(voiceService.transcribedText)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxHeight: 60)
                        } else {
                            Text("Speak now...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Controls
                    HStack(spacing: 30) {
                        // Cancel button
                        Button(action: {
                            voiceService.stopRecording()
                            onCancel()
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                                
                                Text("Cancel")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Stop/Done button
                        Button(action: {
                            voiceService.stopRecording()
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.orange)
                                
                                Text("Done")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 20)
                )
                .padding(.horizontal, 40)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.8)))
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: voiceService.isRecording)
        }
    }
}

// MARK: - Preview
struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            WaveformView(
                audioLevels: [0.1, 0.3, 0.7, 0.5, 0.9, 0.2, 0.6, 0.4],
                isRecording: true
            )
            
            WaveformView(
                audioLevels: [],
                isRecording: false
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
