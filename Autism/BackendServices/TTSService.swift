//
//  TTSService.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import Foundation
import AVFoundation

// MARK: - TTS Service
@MainActor
class TTSService: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var isSpeaking = false
    @Published var isPaused = false
    @Published var currentSpeechRate: Float = AVSpeechUtteranceDefaultSpeechRate
    @Published var currentVoice: AVSpeechSynthesisVoice?
    @Published var speechProgress: Float = 0.0
    @Published var currentlyReadingMessageId: UUID?
    
    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    private var speechQueue: [SpeechItem] = []
    private var isProcessingQueue = false
    
    override init() {
        super.init()
        setupSynthesizer()
        configureAudioSession()
    }
    
    // MARK: - Public Methods
    
    func speak(text: String, messageId: UUID? = nil) {
        print("🔊 TTS request: '\(text.prefix(50))...'")
        
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("🔊 Empty text, skipping TTS")
            return
        }
        
        // Clean text for better speech
        let cleanedText = cleanTextForSpeech(text)
        
        // Create speech item
        let speechItem = SpeechItem(
            text: cleanedText,
            messageId: messageId,
            utterance: createUtterance(from: cleanedText)
        )
        
        // Add to queue and process
        speechQueue.append(speechItem)
        processQueue()
    }
    
    func stopSpeaking() {
        print("🔊 Stopping speech")
        
        synthesizer.stopSpeaking(at: .immediate)
        clearQueue()
        resetState()
    }
    
    func pauseSpeaking() {
        guard isSpeaking && !isPaused else { return }
        
        print("🔊 Pausing speech")
        synthesizer.pauseSpeaking(at: .word)
        isPaused = true
    }
    
    func resumeSpeaking() {
        guard isPaused else { return }
        
        print("🔊 Resuming speech")
        synthesizer.continueSpeaking()
        isPaused = false
    }
    
    func adjustSpeechRate(_ rate: Float) {
        // Clamp rate between 0.1 and 1.0
        let clampedRate = max(0.1, min(1.0, rate))
        currentSpeechRate = clampedRate
        
        print("🔊 Speech rate adjusted to: \(clampedRate)")
        
        // If currently speaking, stop and restart with new rate
        if isSpeaking, let currentText = currentUtterance?.speechString {
            stopSpeaking()
            speak(text: currentText, messageId: currentlyReadingMessageId)
        }
    }
    
    func setVoice(_ voice: AVSpeechSynthesisVoice) {
        currentVoice = voice
        print("🔊 Voice changed to: \(voice.name)")
        
        // If currently speaking, restart with new voice
        if isSpeaking, let currentText = currentUtterance?.speechString {
            stopSpeaking()
            speak(text: currentText, messageId: currentlyReadingMessageId)
        }
    }
    
    func getAvailableVoices() -> [AVSpeechSynthesisVoice] {
        // FIXED: Use only built-in system voices to avoid voice asset query errors
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // Filter for English voices and prefer built-in over downloaded
        let englishVoices = allVoices.filter { voice in
            voice.language.hasPrefix("en") &&
            voice.quality != .premium // Avoid premium voices that might need downloading
        }
        
        // If no voices found, fallback to default
        if englishVoices.isEmpty {
            if let defaultVoice = AVSpeechSynthesisVoice(language: "en-US") {
                return [defaultVoice]
            }
            return []
        }
        
        return englishVoices.sorted { $0.name < $1.name }
    }
    
    // MARK: - Private Methods
    
    private func setupSynthesizer() {
        synthesizer.delegate = self
        
        // Set default voice - use simple fallback to avoid voice asset issues
        currentVoice = findBestVoice()
        
        print("🔊 TTS Service initialized with voice: \(currentVoice?.name ?? "Default")")
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try audioSession.setActive(true)
            print("🔊 Audio session configured for TTS")
        } catch {
            print("🔊 Failed to configure audio session: \(error)")
        }
    }
    
    private func findBestVoice() -> AVSpeechSynthesisVoice? {
        // FIXED: Use simple voice selection to avoid asset queries
        
        // First try default English voices (these are always available)
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            return voice
        }
        
        if let voice = AVSpeechSynthesisVoice(language: "en-GB") {
            return voice
        }
        
        if let voice = AVSpeechSynthesisVoice(language: "en") {
            return voice
        }
        
        // Fallback to any available voice
        return AVSpeechSynthesisVoice.speechVoices().first
    }
    
    private func createUtterance(from text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        
        // Configure utterance
        utterance.rate = currentSpeechRate
        utterance.voice = currentVoice
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1
        
        return utterance
    }
    
    private func cleanTextForSpeech(_ text: String) -> String {
        var cleanedText = text
        
        // Remove markdown formatting
        cleanedText = cleanedText.replacingOccurrences(of: "**", with: "") // Bold
        cleanedText = cleanedText.replacingOccurrences(of: "*", with: "")  // Italic
        cleanedText = cleanedText.replacingOccurrences(of: "###", with: "") // Headers
        cleanedText = cleanedText.replacingOccurrences(of: "##", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "#", with: "")
        
        // Replace bullet points with "Item:"
        cleanedText = cleanedText.replacingOccurrences(of: "• ", with: "Item: ")
        cleanedText = cleanedText.replacingOccurrences(of: "- ", with: "Item: ")
        
        // Replace numbered lists
        let numberPattern = #"^\d+\.\s*"#
        cleanedText = cleanedText.replacingOccurrences(
            of: numberPattern,
            with: "Item ",
            options: .regularExpression
        )
        
        // Normalize whitespace and line breaks
        cleanedText = cleanedText.replacingOccurrences(of: "\n\n+", with: ". ", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "\n", with: " ")
        cleanedText = cleanedText.replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        
        // Trim whitespace
        cleanedText = cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanedText
    }
    
    private func processQueue() {
        guard !isProcessingQueue && !speechQueue.isEmpty else { return }
        
        isProcessingQueue = true
        let nextItem = speechQueue.removeFirst()
        
        currentUtterance = nextItem.utterance
        currentlyReadingMessageId = nextItem.messageId
        
        print("🔊 Starting speech: '\(nextItem.text.prefix(50))...'")
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

// MARK: - AVSpeechSynthesizerDelegate
extension TTSService: AVSpeechSynthesizerDelegate {
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = true
            self.isPaused = false
            self.speechProgress = 0.0
            print("🔊 Speech started")
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            print("🔊 Speech finished")
            
            self.speechProgress = 1.0
            self.isProcessingQueue = false
            
            // Check if there are more items in queue
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
            print("🔊 Speech paused")
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isPaused = false
            print("🔊 Speech resumed")
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            print("🔊 Speech cancelled")
            self.isProcessingQueue = false
            
            // Process next item if available
            if !self.speechQueue.isEmpty {
                self.processQueue()
            } else {
                self.resetState()
            }
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        Task { @MainActor in
            // Update progress based on character position
            let totalLength = utterance.speechString.count
            let currentPosition = characterRange.location
            self.speechProgress = totalLength > 0 ? Float(currentPosition) / Float(totalLength) : 0.0
        }
    }
}

// MARK: - Supporting Models
private struct SpeechItem {
    let text: String
    let messageId: UUID?
    let utterance: AVSpeechUtterance
}

// MARK: - TTS Settings
struct TTSSettings {
    var isEnabled: Bool = true
    var autoPlay: Bool = false  // Auto-play AI responses
    var rate: Float = AVSpeechUtteranceDefaultSpeechRate
    var voiceIdentifier: String?
    
    static let rateRange: ClosedRange<Float> = 0.1...1.0
    
    var voiceName: String {
        guard let identifier = voiceIdentifier,
              let voice = AVSpeechSynthesisVoice(identifier: identifier) else {
            return "Default"
        }
        return voice.name
    }
}

// MARK: - TTS Preferences Manager
@MainActor
class TTSPreferences: ObservableObject {
    @Published var settings = TTSSettings()
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "TTSSettings"
    
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
              let loadedSettings = try? JSONDecoder().decode(TTSSettings.self, from: data) else {
            return
        }
        settings = loadedSettings
    }
}

// Make TTSSettings Codable
extension TTSSettings: Codable {}
