//
//  TTSUIComponents.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/8/25.
//

//
//  TTSUIComponents.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI
import AVFoundation

// MARK: - TTS Message Controls
struct TTSMessageControls: View {
    let message: Message
    @ObservedObject var ttsService: TTSService
    let isCurrentlyReading: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // Play/Pause/Stop button
            Button(action: togglePlayback) {
                HStack(spacing: 4) {
                    Image(systemName: playButtonIcon)
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text(playButtonText)
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Reading progress indicator
            if isCurrentlyReading && ttsService.speechProgress > 0 {
                ProgressView(value: ttsService.speechProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .frame(width: 60, height: 2)
                    .scaleEffect(0.8)
            }
            
            Spacer()
        }
        .animation(.easeInOut(duration: 0.2), value: isCurrentlyReading)
        .animation(.easeInOut(duration: 0.2), value: ttsService.isSpeaking)
    }
    
    private var playButtonIcon: String {
        if isCurrentlyReading {
            return ttsService.isPaused ? "play.fill" : "pause.fill"
        } else if ttsService.isSpeaking {
            return "stop.fill"
        } else {
            return "speaker.wave.2.fill"
        }
    }
    
    private var playButtonText: String {
        if isCurrentlyReading {
            return ttsService.isPaused ? "Resume" : "Pause"
        } else if ttsService.isSpeaking {
            return "Stop"
        } else {
            return "Listen"
        }
    }
    
    private func togglePlayback() {
        if isCurrentlyReading {
            // Currently reading this message
            if ttsService.isPaused {
                ttsService.resumeSpeaking()
            } else {
                ttsService.pauseSpeaking()
            }
        } else if ttsService.isSpeaking {
            // Reading a different message - stop current and start this one
            ttsService.stopSpeaking()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                ttsService.speak(text: message.text, messageId: message.id)
            }
        } else {
            // Not reading anything - start reading this message
            ttsService.speak(text: message.text, messageId: message.id)
        }
    }
}

// MARK: - TTS Quick Controls
struct TTSQuickControls: View {
    @ObservedObject var ttsService: TTSService
    
    var body: some View {
        HStack(spacing: 8) {
            // Pause/Resume button
            Button(action: {
                if ttsService.isPaused {
                    ttsService.resumeSpeaking()
                } else {
                    ttsService.pauseSpeaking()
                }
            }) {
                Image(systemName: ttsService.isPaused ? "play.fill" : "pause.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(width: 20, height: 20)
            }
            
            // Stop button
            Button(action: {
                ttsService.stopSpeaking()
            }) {
                Image(systemName: "stop.fill")
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - TTS Status Overlay
struct TTSStatusOverlay: View {
    @ObservedObject var ttsService: TTSService
    
    var body: some View {
        if ttsService.isSpeaking {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Speaking indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.orange)
                            .frame(width: 6, height: 6)
                            .scaleEffect(1.2)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: ttsService.isSpeaking)
                        
                        Text(ttsService.isPaused ? "Speech Paused" : "Reading Message")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Controls
                    TTSQuickControls(ttsService: ttsService)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Rectangle()
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                
                // Progress bar
                if ttsService.speechProgress > 0 {
                    ProgressView(value: ttsService.speechProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                        .frame(height: 2)
                }
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - TTS Settings Sheet
struct TTSSettingsSheet: View {
    @ObservedObject var ttsService: TTSService
    @ObservedObject var preferences: TTSPreferences
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedVoice: AVSpeechSynthesisVoice?
    @State private var tempSettings: TTSSettings
    
    init(ttsService: TTSService, preferences: TTSPreferences) {
        self.ttsService = ttsService
        self.preferences = preferences
        self._tempSettings = State(initialValue: preferences.settings)
        self._selectedVoice = State(initialValue: ttsService.currentVoice)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // TTS Enable/Disable
                Section {
                    Toggle("Enable Text-to-Speech", isOn: $tempSettings.isEnabled)
                        .tint(.orange)
                } header: {
                    Text("Text-to-Speech")
                } footer: {
                    Text("When enabled, AI responses can be read aloud automatically or on demand.")
                }
                
                if tempSettings.isEnabled {
                    // Auto-play setting
                    Section {
                        Toggle("Auto-play AI Responses", isOn: $tempSettings.autoPlay)
                            .tint(.orange)
                    } footer: {
                        Text("Automatically read AI responses aloud when they arrive.")
                    }
                    
                    // Speech Rate
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Speech Rate")
                                Spacer()
                                Text("\(Int(tempSettings.rate * 100))%")
                                    .foregroundColor(.secondary)
                            }
                            
                            Slider(value: $tempSettings.rate, in: TTSSettings.rateRange, step: 0.1) {
                                Text("Speech Rate")
                            } minimumValueLabel: {
                                Text("0.1x")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } maximumValueLabel: {
                                Text("1.0x")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tint(.orange)
                            
                            // Test button
                            Button("Test Speech Rate") {
                                testCurrentSettings()
                            }
                            .font(.caption)
                            .foregroundColor(.orange)
                        }
                    } footer: {
                        Text("Adjust how fast the text is spoken. 1.0x is normal speed.")
                    }
                    
                    // Voice Selection
                    Section {
                        ForEach(ttsService.getAvailableVoices(), id: \.identifier) { voice in
                            Button(action: {
                                selectedVoice = voice
                                tempSettings.voiceIdentifier = voice.identifier
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(voice.name)
                                            .foregroundColor(.primary)
                                        
                                        Text(voiceDescription(voice))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedVoice?.identifier == voice.identifier {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.orange)
                                    }
                                    
                                    Button("Test") {
                                        testVoice(voice)
                                    }
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .onTapGesture {
                                        testVoice(voice)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Voice Selection")
                    } footer: {
                        Text("Choose the voice that will read text aloud. Tap 'Test' to hear a sample.")
                    }
                    
                    // Current Status
                    if ttsService.isSpeaking {
                        Section {
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.orange)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Currently Speaking")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    if ttsService.speechProgress > 0 {
                                        ProgressView(value: ttsService.speechProgress)
                                            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                                    }
                                }
                                
                                Spacer()
                                
                                Button(ttsService.isPaused ? "Resume" : "Pause") {
                                    if ttsService.isPaused {
                                        ttsService.resumeSpeaking()
                                    } else {
                                        ttsService.pauseSpeaking()
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.orange)
                                
                                Button("Stop") {
                                    ttsService.stopSpeaking()
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Voice Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onDisappear {
            // Stop any test speech when closing
            ttsService.stopSpeaking()
        }
    }
    
    private func voiceDescription(_ voice: AVSpeechSynthesisVoice) -> String {
        var description = voice.language
        
        if voice.quality == .enhanced {
            description += " • Enhanced"
        }
        
        // Add gender hints based on common voice names
        let femalNames = ["samantha", "susan", "karen", "tessa", "moira", "fiona"]
        let maleName = ["alex", "tom", "daniel", "fred"]
        
        let lowercaseName = voice.name.lowercased()
        if femalNames.contains(where: { lowercaseName.contains($0) }) {
            description += " • Female"
        } else if maleName.contains(where: { lowercaseName.contains($0) }) {
            description += " • Male"
        }
        
        return description
    }
    
    private func testVoice(_ voice: AVSpeechSynthesisVoice) {
        ttsService.stopSpeaking()
        
        // Temporarily set the voice and rate for testing
        //let originalVoice = ttsService.currentVoice
        //let originalRate = ttsService.currentSpeechRate
        
        ttsService.setVoice(voice)
        ttsService.adjustSpeechRate(tempSettings.rate)
        
        // Test with sample text
        let testText = "Hello! This is how I sound when reading your messages. You can adjust my speaking rate and choose different voices."
        ttsService.speak(text: testText)
        
        // Note: In a production app, you might want to restore original settings after test
        // For now, we'll let the user hear the test with current settings
    }
    
    private func testCurrentSettings() {
        // Apply current temp settings
        ttsService.adjustSpeechRate(tempSettings.rate)
        if let voice = selectedVoice {
            ttsService.setVoice(voice)
        }
        
        let testText = "This is a test of your current speech settings. The rate is set to \(Int(tempSettings.rate * 100)) percent."
        ttsService.speak(text: testText)
    }
    
    private func saveSettings() {
        // Apply settings to TTS service
        if let voice = selectedVoice {
            ttsService.setVoice(voice)
        }
        ttsService.adjustSpeechRate(tempSettings.rate)
        
        // Save to preferences
        preferences.settings = tempSettings
        preferences.saveSettings()
        
        print("🔊 TTS settings saved")
    }
}

// MARK: - TTS Accessibility Controls
struct TTSAccessibilityControls: View {
    @ObservedObject var ttsService: TTSService
    let message: Message
    
    var body: some View {
        Button(action: {
            if ttsService.currentlyReadingMessageId == message.id {
                if ttsService.isPaused {
                    ttsService.resumeSpeaking()
                } else {
                    ttsService.pauseSpeaking()
                }
            } else {
                ttsService.speak(text: message.text, messageId: message.id)
            }
        }) {
            Image(systemName: "speaker.wave.2")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .accessibilityLabel("Read message aloud")
        .accessibilityHint("Double tap to have this message read using text-to-speech")
    }
}

// MARK: - TTS Speed Control
struct TTSSpeedControl: View {
    @ObservedObject var ttsService: TTSService
    @Binding var speed: Float
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Speed")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(speed * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
            }
            
            HStack(spacing: 12) {
                Button(action: { adjustSpeed(-0.1) }) {
                    Image(systemName: "minus.circle")
                        .foregroundColor(.orange)
                }
                
                Slider(value: $speed, in: 0.1...1.0, step: 0.1)
                    .tint(.orange)
                    .onChange(of: speed) { oldValue, newValue in
                        ttsService.adjustSpeechRate(newValue)
                    }
                
                Button(action: { adjustSpeed(0.1) }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
    
    private func adjustSpeed(_ delta: Float) {
        let newSpeed = max(0.1, min(1.0, speed + delta))
        speed = newSpeed
        ttsService.adjustSpeechRate(newSpeed)
    }
}

// MARK: - TTS Voice Picker
struct TTSVoicePicker: View {
    @ObservedObject var ttsService: TTSService
    @Binding var selectedVoice: AVSpeechSynthesisVoice?
    
    var body: some View {
        Menu {
            ForEach(ttsService.getAvailableVoices(), id: \.identifier) { voice in
                Button(voice.name) {
                    selectedVoice = voice
                    ttsService.setVoice(voice)
                }
            }
        } label: {
            HStack {
                Text("Voice: \(selectedVoice?.name ?? "Default")")
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.systemGray6))
            .cornerRadius(6)
        }
    }
}
