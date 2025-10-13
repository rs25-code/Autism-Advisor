//
//  LanguageSelectorUI.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI
import AVFoundation

// MARK: - Language Selector Toggle
struct LanguageSelector: View {
    @Binding var selectedLanguage: SupportedLanguage
    let onLanguageChange: (SupportedLanguage) -> Void
    
    var body: some View {
        Menu {
            ForEach(SupportedLanguage.allCases, id: \.self) { language in
                Button(action: {
                    selectedLanguage = language
                    onLanguageChange(language)
                }) {
                    HStack {
                        Text("\(language.flag) \(language.displayName)")
                        
                        if selectedLanguage == language {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selectedLanguage.flag)
                    .font(.caption)
                
                Text(selectedLanguage.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
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
        .accessibilityLabel("Language: \(selectedLanguage.displayName)")
        .accessibilityHint("Double tap to change language")
    }
}

// MARK: - Quick Language Toggle
struct QuickLanguageToggle: View {
    @Binding var selectedLanguage: SupportedLanguage
    let onLanguageChange: (SupportedLanguage) -> Void
    
    var body: some View {
        Button(action: {
            let newLanguage: SupportedLanguage = selectedLanguage == .english ? .spanish : .english
            selectedLanguage = newLanguage
            onLanguageChange(newLanguage)
        }) {
            HStack(spacing: 4) {
                Text(selectedLanguage.flag)
                    .font(.caption)
                
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(6)
        }
        .accessibilityLabel("Switch to \(selectedLanguage == .english ? "Spanish" : "English")")
    }
}

// MARK: - Multilingual TTS Service
@MainActor
class MultilingualTTSService: NSObject, ObservableObject {
    @Published var isSpeaking = false
    @Published var isPaused = false
    @Published var speechProgress: Float = 0.0
    @Published var currentlyReadingMessageId: UUID?
    @Published var currentLanguage: SupportedLanguage = .english
    @Published var isLoading = false
    
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    private var speechQueue: [MultilingualSpeechItem] = []
    private var isProcessingQueue = false
    private var selectedVoices: [SupportedLanguage: AVSpeechSynthesisVoice] = [:]
    
    override init() {
        super.init()
        synthesizer.delegate = self
        setupDefaultVoices()
    }
    
    private func setupDefaultVoices() {
        // Set up default voices for each language
        selectedVoices[.english] = findBestVoice(for: .english)
        selectedVoices[.spanish] = findBestVoice(for: .spanish)
    }
    
    private func findBestVoice(for language: SupportedLanguage) -> AVSpeechSynthesisVoice? {
        let languageCode = language.voiceLanguageCode
        
        // Try to find a high-quality voice for the language
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()
        let languageVoices = availableVoices.filter { $0.language.hasPrefix(languageCode.prefix(2)) }
        
        // Prefer enhanced quality voices
        if let enhancedVoice = languageVoices.first(where: { $0.quality == .enhanced }) {
            return enhancedVoice
        }
        
        // Fallback to default voice for language
        return AVSpeechSynthesisVoice(language: languageCode) ?? languageVoices.first
    }
    
    func speak(text: String, messageId: UUID? = nil, language: SupportedLanguage? = nil) {
        let targetLanguage = language ?? currentLanguage
        currentLanguage = targetLanguage
        
        let cleanedText = cleanTextForSpeech(text)
        guard !cleanedText.isEmpty else { return }
        
        let speechItem = MultilingualSpeechItem(
            text: cleanedText,
            messageId: messageId,
            language: targetLanguage,
            utterance: createUtterance(from: cleanedText, language: targetLanguage)
        )
        
        speechQueue.append(speechItem)
        processQueue()
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        clearQueue()
        resetState()
    }
    
    func pauseSpeaking() {
        guard isSpeaking && !isPaused else { return }
        synthesizer.pauseSpeaking(at: .word)
        isPaused = true
    }
    
    func resumeSpeaking() {
        guard isPaused else { return }
        synthesizer.continueSpeaking()
        isPaused = false
    }
    
    func setVoice(_ voice: AVSpeechSynthesisVoice, for language: SupportedLanguage) {
        selectedVoices[language] = voice
    }
    
    func adjustSpeechRate(_ rate: Float) {
        // Implementation for adjusting speech rate
    }
    
    func getAvailableVoices(for language: SupportedLanguage? = nil) -> [AVSpeechSynthesisVoice] {
        let targetLanguage = language ?? currentLanguage
        let languageCode = targetLanguage.voiceLanguageCode
        
        return AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix(languageCode.prefix(2)) }
            .sorted { $0.name < $1.name }
    }
    
    private func createUtterance(from text: String, language: SupportedLanguage) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = selectedVoices[language]
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0
        return utterance
    }
    
    private func cleanTextForSpeech(_ text: String) -> String {
        var cleanedText = text
        
        // Remove markdown formatting
        cleanedText = cleanedText.replacingOccurrences(of: "**", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "*", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "###", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "##", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "#", with: "")
        
        // Replace bullet points
        cleanedText = cleanedText.replacingOccurrences(of: "• ", with: "Item: ")
        cleanedText = cleanedText.replacingOccurrences(of: "- ", with: "Item: ")
        
        // Normalize whitespace
        cleanedText = cleanedText.replacingOccurrences(of: "\n\n+", with: ". ", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "\n", with: " ")
        cleanedText = cleanedText.replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        
        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func processQueue() {
        guard !isProcessingQueue && !speechQueue.isEmpty else { return }
        
        isProcessingQueue = true
        let nextItem = speechQueue.removeFirst()
        
        currentUtterance = nextItem.utterance
        currentlyReadingMessageId = nextItem.messageId
        currentLanguage = nextItem.language
        
        synthesizer.speak(nextItem.utterance)
    }
    
    private func clearQueue() {
        speechQueue.removeAll()
        isProcessingQueue = false
    }
    
    private func resetState() {
        isSpeaking = false
        isPaused = false
        speechProgress = 0.0
        currentlyReadingMessageId = nil
        currentUtterance = nil
    }
}

// MARK: - AVSpeechSynthesizerDelegate for MultilingualTTSService
extension MultilingualTTSService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = true
            self.isPaused = false
            self.speechProgress = 0.0
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.speechProgress = 1.0
            self.isProcessingQueue = false
            
            if !self.speechQueue.isEmpty {
                self.processQueue()
            } else {
                self.resetState()
            }
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isPaused = true
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isPaused = false
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isProcessingQueue = false
            
            if !self.speechQueue.isEmpty {
                self.processQueue()
            } else {
                self.resetState()
            }
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        Task { @MainActor in
            let totalLength = utterance.speechString.count
            let currentPosition = characterRange.location
            self.speechProgress = totalLength > 0 ? Float(currentPosition) / Float(totalLength) : 0.0
        }
    }
}

// MARK: - Multilingual TTS Settings
struct MultilingualTTSSettings {
    var isEnabled: Bool = true
    var autoPlay: Bool = false
    var rate: Float = AVSpeechUtteranceDefaultSpeechRate
    var voiceIdentifiers: [String: String] = [:] // Language code to voice identifier mapping
    
    static let rateRange: ClosedRange<Float> = 0.1...1.0
}

// MARK: - Multilingual TTS Preferences Manager
@MainActor
class MultilingualTTSPreferences: ObservableObject {
    @Published var settings = MultilingualTTSSettings()
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "MultilingualTTSSettings"
    
    init() {
        loadSettings()
    }
    
    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: settingsKey)
        }
    }
    
    private func loadSettings() {
        guard let data = userDefaults.data(forKey: settingsKey),
              let loadedSettings = try? JSONDecoder().decode(MultilingualTTSSettings.self, from: data) else {
            return
        }
        settings = loadedSettings
    }
}

// MARK: - Enhanced TTS Settings Sheet with Language Support
struct MultilingualTTSSettingsSheet: View {
    @ObservedObject var ttsService: MultilingualTTSService
    @ObservedObject var preferences: MultilingualTTSPreferences
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempSettings: MultilingualTTSSettings
    @State private var selectedVoices: [SupportedLanguage: AVSpeechSynthesisVoice] = [:]
    
    init(ttsService: MultilingualTTSService, preferences: MultilingualTTSPreferences) {
        self.ttsService = ttsService
        self.preferences = preferences
        self._tempSettings = State(initialValue: preferences.settings)
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
                            
                            Slider(value: $tempSettings.rate, in: MultilingualTTSSettings.rateRange, step: 0.1) {
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
                    
                    // Language-specific voice selection
                    ForEach(SupportedLanguage.allCases, id: \.self) { language in
                        Section {
                            ForEach(ttsService.getAvailableVoices(for: language), id: \.identifier) { voice in
                                Button(action: {
                                    selectedVoices[language] = voice
                                    tempSettings.voiceIdentifiers[language.rawValue] = voice.identifier
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
                                        
                                        if selectedVoices[language]?.identifier == voice.identifier {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.orange)
                                        }
                                        
                                        Button("Test") {
                                            testVoice(voice, language: language)
                                        }
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    }
                                }
                            }
                        } header: {
                            Text("\(language.flag) \(language.displayName) Voices")
                        }
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
                                    
                                    Text("Language: \(ttsService.currentLanguage.displayName)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
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
            ttsService.stopSpeaking()
        }
    }
    
    private func voiceDescription(_ voice: AVSpeechSynthesisVoice) -> String {
        var description = voice.language
        
        if voice.quality == .enhanced {
            description += " • Enhanced"
        }
        
        // Add gender hints based on common voice names
        let femaleNames = ["samantha", "susan", "karen", "tessa", "moira", "fiona", "paulina", "monica", "lucia"]
        let maleNames = ["alex", "tom", "daniel", "fred", "diego", "carlos"]
        
        let lowercaseName = voice.name.lowercased()
        if femaleNames.contains(where: { lowercaseName.contains($0) }) {
            description += " • Female"
        } else if maleNames.contains(where: { lowercaseName.contains($0) }) {
            description += " • Male"
        }
        
        return description
    }
    
    private func testVoice(_ voice: AVSpeechSynthesisVoice, language: SupportedLanguage) {
        ttsService.stopSpeaking()
        
        ttsService.setVoice(voice, for: language)
        ttsService.adjustSpeechRate(tempSettings.rate)
        
        let testText = language == .spanish ?
            "Hola! Así es como sueno cuando leo tus mensajes. Puedes ajustar mi velocidad de habla y elegir diferentes voces." :
            "Hello! This is how I sound when reading your messages. You can adjust my speaking rate and choose different voices."
        
        ttsService.speak(text: testText, language: language)
    }
    
    private func testCurrentSettings() {
        ttsService.adjustSpeechRate(tempSettings.rate)
        
        let testText = ttsService.currentLanguage == .spanish ?
            "Esta es una prueba de tus configuraciones actuales de voz. La velocidad está configurada al \(Int(tempSettings.rate * 100)) por ciento." :
            "This is a test of your current speech settings. The rate is set to \(Int(tempSettings.rate * 100)) percent."
        
        ttsService.speak(text: testText, language: ttsService.currentLanguage)
    }
    
    private func saveSettings() {
        // Apply settings to TTS service
        for (language, voice) in selectedVoices {
            ttsService.setVoice(voice, for: language)
        }
        ttsService.adjustSpeechRate(tempSettings.rate)
        
        // Save to preferences
        preferences.settings = tempSettings
        preferences.saveSettings()
        
        print("🔊 Multilingual TTS settings saved")
    }
}

// MARK: - Language Status Indicator
struct LanguageStatusIndicator: View {
    let currentLanguage: SupportedLanguage
    let isDetected: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Text(currentLanguage.flag)
                .font(.caption2)
            
            if isDetected {
                Image(systemName: "brain.head.profile")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(Color(.systemGray6))
        .cornerRadius(4)
        .accessibilityLabel("Current language: \(currentLanguage.displayName)\(isDetected ? " (auto-detected)" : "")")
    }
}

// MARK: - Enhanced Auto-play Toggle with Language Awareness
struct MultilingualTTSAutoPlayToggle: View {
    @ObservedObject var ttsPreferences: TTSPreferences
    let currentLanguage: SupportedLanguage
    
    var body: some View {
        HStack(spacing: 6) {
            Button(action: {
                ttsPreferences.settings.autoPlay.toggle()
                ttsPreferences.saveSettings()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: ttsPreferences.settings.autoPlay ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.caption)
                        .foregroundColor(ttsPreferences.settings.autoPlay ? .orange : .secondary)
                    
                    Text("Auto")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(ttsPreferences.settings.autoPlay ? .orange : .secondary)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(ttsPreferences.settings.autoPlay ? Color.orange.opacity(0.1) : Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(ttsPreferences.settings.autoPlay ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                )
            }
            
            // Language indicator
            LanguageStatusIndicator(
                currentLanguage: currentLanguage,
                isDetected: true
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Auto-play \(ttsPreferences.settings.autoPlay ? "enabled" : "disabled") for \(currentLanguage.displayName)")
    }
}

// MARK: - Supporting Data Models
private struct MultilingualSpeechItem {
    let text: String
    let messageId: UUID?
    let language: SupportedLanguage
    let utterance: AVSpeechUtterance
}

// MARK: - Codable Extensions
extension MultilingualTTSSettings: Codable {}
