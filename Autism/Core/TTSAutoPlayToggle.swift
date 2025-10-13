//
//  TTSAutoPlayToggle.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI

// MARK: - Auto-play Toggle Component
struct TTSAutoPlayToggle: View {
    @ObservedObject var ttsPreferences: TTSPreferences
    
    var body: some View {
        Button(action: {
            ttsPreferences.settings.autoPlay.toggle()
            ttsPreferences.saveSettings()
        }) {
            HStack(spacing: 6) {
                Image(systemName: ttsPreferences.settings.autoPlay ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.caption)
                    .foregroundColor(ttsPreferences.settings.autoPlay ? .orange : .secondary)
                
                Text("Auto")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(ttsPreferences.settings.autoPlay ? .orange : .secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(ttsPreferences.settings.autoPlay ? Color.orange.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(ttsPreferences.settings.autoPlay ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .accessibilityLabel(ttsPreferences.settings.autoPlay ? "Auto-play enabled" : "Auto-play disabled")
        .accessibilityHint("Double tap to toggle automatic reading of AI responses")
    }
}

// MARK: - Enhanced TTS Header Controls
struct TTSHeaderControls: View {
    @ObservedObject var ttsService: TTSService
    @ObservedObject var ttsPreferences: TTSPreferences
    @Binding var showingTTSSettings: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // Auto-play toggle
            TTSAutoPlayToggle(ttsPreferences: ttsPreferences)
            
            // Quick controls when speaking
            if ttsService.isSpeaking {
                TTSQuickControls(ttsService: ttsService)
            }
            
            // Settings button
            Button(action: {
                showingTTSSettings = true
            }) {
                Image(systemName: "speaker.wave.2.circle")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .accessibilityLabel("Voice settings")
        }
    }
}
