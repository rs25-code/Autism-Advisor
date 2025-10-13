//
//  VoiceInputService.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import Foundation
import Speech
import AVFoundation

// MARK: - Voice Input Service
@MainActor
class VoiceInputService: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var audioLevels: [Float] = []
    @Published var permissionStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    @Published var hasError = false
    @Published var errorMessage = ""
    
    // MARK: - Private Properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var audioLevelTimer: Timer?
    
    // MARK: - Constants
    private let maxRecordingDuration: TimeInterval = 60.0 // 1 minute max
    private let audioLevelUpdateInterval: TimeInterval = 0.1 // 100ms updates
    
    override init() {
        super.init()
        setupSpeechRecognizer()
    }
    
    // MARK: - Public Methods
    
    func requestPermissions() async -> Bool {
        // Request microphone permission
        let microphoneStatus = await requestMicrophonePermission()
        
        // Request speech recognition permission
        let speechStatus = await requestSpeechPermission()
        
        await MainActor.run {
            self.permissionStatus = speechStatus
        }
        
        return microphoneStatus && speechStatus == .authorized
    }
    
    func startRecording() async {
        guard !isRecording else { return }
        
        // Check permissions first
        let hasPermission = await requestPermissions()
        guard hasPermission else {
            await showError("Microphone and speech recognition permissions are required")
            return
        }
        
        // FIXED: Simplified error handling - no try-catch since we handle errors inside startSpeechRecognition
        await startSpeechRecognition()
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        print("🎤 Stopping recording...")
        
        // FIXED: Capture the current transcription before stopping
        let finalTranscription = transcribedText
        
        // Stop audio level monitoring first
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        
        // Stop audio engine
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // Finish recognition gracefully
        recognitionRequest?.endAudio()
        
        // Give a moment for final transcription, then cancel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.recognitionTask?.cancel()
            self.recognitionTask = nil
            self.recognitionRequest = nil
        }
        
        // Update UI state
        isRecording = false
        audioLevels = []
        
        // FIXED: Ensure we keep the transcription even after cancellation
        if !finalTranscription.isEmpty {
            transcribedText = finalTranscription
        }
        
        print("🎤 Recording stopped with transcription: '\(finalTranscription)'")
    }
    
    func clearTranscription() {
        transcribedText = ""
    }
    
    // MARK: - Private Methods
    
    private func setupSpeechRecognizer() {
        speechRecognizer?.delegate = self
        
        // Check initial permission status
        permissionStatus = SFSpeechRecognizer.authorizationStatus()
    }
    
    private func requestMicrophonePermission() async -> Bool {
        // FIXED: AVAudioApplication.requestRecordPermission() doesn't throw, it just returns Bool
        if #available(iOS 17.0, *) {
            return await AVAudioApplication.requestRecordPermission()
        } else {
            return await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    private func requestSpeechPermission() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }
    
    private func startSpeechRecognition() async {
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // FIXED: Handle each throwing call individually instead of wrapping in do-catch
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        } catch {
            await showError("Failed to configure audio session: \(error.localizedDescription)")
            return
        }
        
        do {
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            await showError("Failed to activate audio session: \(error.localizedDescription)")
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            await showError("Failed to create speech recognition request")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Get audio input node
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Install audio tap for recognition
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
            
            // Calculate audio level for waveform
            self.updateAudioLevel(from: buffer)
        }
        
        // Prepare and start audio engine
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            await showError("Failed to start audio engine: \(error.localizedDescription)")
            return
        }
        
        // Start recognition task
        await MainActor.run {
            self.isRecording = true
            self.transcribedText = ""
            self.hasError = false
            self.startAudioLevelTimer()
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let result = result {
                    self.transcribedText = result.bestTranscription.formattedString
                    
                    // If result is final, stop recording
                    if result.isFinal {
                        self.stopRecording()
                    }
                }
                
                if let error = error {
                    print("🎤 Speech recognition error: \(error)")
                    
                    // FIXED: Don't show error for cancellation - this is normal when user taps Done
                    let nsError = error as NSError
                    if nsError.domain == "kLSRErrorDomain" && nsError.code == 301 {
                        // Code 301 = Recognition request was canceled (normal behavior)
                        print("🎤 Recognition canceled by user (normal)")
                        self.stopRecording()
                    } else if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 1110 {
                        // Code 1110 = No speech detected (also normal)
                        print("🎤 No speech detected (normal)")
                        self.stopRecording()
                    } else {
                        // Only show error for unexpected issues
                        self.stopRecording()
                        await self.showError("Speech recognition failed: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // Auto-stop after max duration
        DispatchQueue.main.asyncAfter(deadline: .now() + maxRecordingDuration) {
            if self.isRecording {
                self.stopRecording()
            }
        }
        
        print("🎤 Recording started")
    }
    
    private func updateAudioLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        
        let frameLength = Int(buffer.frameLength)
        var sum: Float = 0
        
        // Calculate RMS (Root Mean Square) for audio level
        for i in 0..<frameLength {
            sum += channelData[i] * channelData[i]
        }
        
        let rms = sqrt(sum / Float(frameLength))
        let level = max(0.0, min(1.0, rms * 10)) // Scale and clamp
        
        Task { @MainActor in
            // Keep only recent levels for waveform
            self.audioLevels.append(level)
            if self.audioLevels.count > 50 { // Keep last 50 samples
                self.audioLevels.removeFirst()
            }
        }
    }
    
    private func startAudioLevelTimer() {
        audioLevelTimer = Timer.scheduledTimer(withTimeInterval: audioLevelUpdateInterval, repeats: true) { _ in
            // Timer ensures regular updates even if audio is quiet
            Task { @MainActor in
                if self.audioLevels.isEmpty {
                    self.audioLevels.append(0.0)
                }
            }
        }
    }
    
    private func showError(_ message: String) async {
        await MainActor.run {
            self.errorMessage = message
            self.hasError = true
            print("🎤 Error: \(message)")
        }
    }
}

// MARK: - SFSpeechRecognizerDelegate
extension VoiceInputService: SFSpeechRecognizerDelegate {
    nonisolated func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        Task { @MainActor in
            if !available {
                self.stopRecording()
                await self.showError("Speech recognition is not available")
            }
        }
    }
}

// MARK: - Voice Input Errors
enum VoiceInputError: LocalizedError {
    case failedToCreateRequest
    case permissionDenied
    case recognitionFailed
    
    var errorDescription: String? {
        switch self {
        case .failedToCreateRequest:
            return "Failed to create speech recognition request"
        case .permissionDenied:
            return "Microphone or speech recognition permission denied"
        case .recognitionFailed:
            return "Speech recognition failed"
        }
    }
}
