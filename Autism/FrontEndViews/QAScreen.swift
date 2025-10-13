//
//  QAScreen.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI

struct QAScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var messageText = ""
    @State private var showingDocumentPicker = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isMessageFieldFocused: Bool
    
    // Voice and TTS services
    @StateObject private var voiceService = VoiceInputService()
    @StateObject private var ttsService = TTSService()
    @StateObject private var ttsPreferences = TTSPreferences()
    
    // TTS UI State
    @State private var showingTTSSettings = false
    
    var body: some View {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Main Content
                if appState.hasActiveDocument {
                    if let chatSession = appState.chatSession {
                        // Active Chat
                        activeChatView(chatSession)
                    } else {
                        // Start Chat
                        startChatView
                    }
                } else {
                    // No Document
                    noDocumentView
                }
            }
            .navigationTitle("Ask Questions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // TTS Settings
                        Button(action: { showingTTSSettings = true }) {
                            Label("Voice Settings", systemImage: "speaker.wave.2")
                        }
                        
                        if appState.hasActiveDocument {
                            Button("New Chat") {
                                startNewChat()
                            }
                            
                            Button("Clear Messages") {
                                clearChat()
                            }
                        }
                        
                        Button("Upload Document") {
                            appState.navigate(to: .upload)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            initializeChatIfNeeded()
        }
        .sheet(isPresented: $showingTTSSettings) {
            TTSSettingsSheet(ttsService: ttsService, preferences: ttsPreferences)
        }
        // Voice recording overlay
        .overlay(
            VoiceRecordingOverlay(voiceService: voiceService) {
                // On cancel - clear any partial transcription
                voiceService.clearTranscription()
            }
        )
        // TTS Status overlay
        .overlay(
            TTSStatusOverlay(ttsService: ttsService)
                .opacity(ttsService.isSpeaking ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: ttsService.isSpeaking),
            alignment: .top
        )
        // Stop TTS when leaving screen
        .onDisappear {
            ttsService.stopSpeaking()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            if let iep = appState.currentIEP {
                HStack(spacing: 12) {
                    // Document Icon
                    Image(systemName: "doc.text.fill")
                        .font(.title3)
                        .foregroundColor(ColorTheme.primary)
                        .frame(width: 32, height: 32)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    
                    // Document Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(iep.studentName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(iep.fileName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // TTS and Chat Controls
                    VStack(alignment: .trailing, spacing: 8) {
                        // TTS Controls (Auto-play toggle and quick controls)
                        TTSHeaderControls(
                            ttsService: ttsService,
                            ttsPreferences: ttsPreferences,
                            showingTTSSettings: $showingTTSSettings
                        )
                        
                        // Chat Status
                        if let session = appState.chatSession {
                            HStack(spacing: 8) {
                                Text("\(session.messageCount) messages")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Text("Active")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.1))
                                    .foregroundColor(.green)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Active Chat View
    private func activeChatView(_ session: ChatSession) -> some View {
        VStack(spacing: 0) {
            // Messages Area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(session.messages) { message in
                            MessageBubbleView(
                                message: message,
                                ttsService: ttsService,
                                isCurrentlyReading: ttsService.currentlyReadingMessageId == message.id
                            )
                            .id(message.id)
                        }
                        
                        // Typing Indicator
                        if appState.openAIService.isLoading {
                            TypingIndicatorView()
                                .id("typing")
                        }
                    }
                    .padding()
                }
                .onChange(of: session.messages.count) { oldCount, newCount in
                    // Auto-scroll to latest message
                    if let lastMessage = session.messages.last {
                        withAnimation(.easeOut(duration: 0.5)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                        
                        // Auto-play TTS for AI responses if enabled
                        if !lastMessage.isFromUser &&
                           lastMessage.messageType == .text &&
                           ttsPreferences.settings.autoPlay {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                ttsService.speak(text: lastMessage.text, messageId: lastMessage.id)
                            }
                        }
                    }
                }
            }
            
            // Message Input
            messageInputView
        }
    }
    
    // MARK: - Message Input View
    private var messageInputView: some View {
        VStack(spacing: 12) {
            // Quick Questions
            if let session = appState.chatSession, session.messageCount == 1 { // Only welcome message
                quickQuestionsView
            }
            
            // Input Field with Voice Support
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    TextField("Ask a question about this document...", text: $messageText, axis: .vertical)
                        .focused($isMessageFieldFocused)
                        .lineLimit(1...4)
                        .onSubmit {
                            sendMessage()
                        }
                    
                    if !messageText.isEmpty {
                        Button(action: { messageText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                
                // Voice Input Button
                VoiceInputButton(voiceService: voiceService) { transcribedText in
                    messageText = transcribedText.trimmingCharacters(in: .whitespacesAndNewlines)
                    isMessageFieldFocused = true
                }
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.isEmpty ? .secondary : .orange)
                }
                .disabled(messageText.isEmpty || appState.openAIService.isLoading)
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Quick Questions View
    private var quickQuestionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Questions")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(getSuggestedQuestions(), id: \.self) { question in
                        Button(question) {
                            selectQuickQuestion(question)
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(ColorTheme.primary)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Start Chat View
    private var startChatView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "message.fill")
                        .font(.system(size: 36))
                        .foregroundColor(ColorTheme.primary)
                }
                
                // Title and Description
                VStack(spacing: 8) {
                    Text("Start Conversation")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Ask questions about \(appState.currentIEP?.studentName ?? "the document") and get AI-powered insights")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Sample Questions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Try asking:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(getSampleQuestions(), id: \.self) { question in
                            HStack(spacing: 8) {
                                Image(systemName: "message.badge")
                                    .font(.caption)
                                    .foregroundColor(ColorTheme.primary)
                                
                                Text(question)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
                
                // Start Button
                Button("Start Chat") {
                    startNewChatSession()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - No Document View
    private var noDocumentView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                }
                
                // Title and Description
                VStack(spacing: 8) {
                    Text("No Document Available")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Upload a document first to start asking questions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Upload Document") {
                        appState.navigate(to: .upload)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    if appState.hasDocumentHistory {
                        Button("Select from History") {
                            // Show document history
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func initializeChatIfNeeded() {
        // Only initialize if we have a document but no chat session
        if appState.hasActiveDocument && appState.chatSession == nil {
            DispatchQueue.main.async {
                appState.startChatSession()
            }
        }
    }
    
    private func startNewChat() {
        ttsService.stopSpeaking()
        DispatchQueue.main.async {
            appState.clearChatSession()
            appState.startChatSession()
        }
    }
    
    private func clearChat() {
        ttsService.stopSpeaking()
        DispatchQueue.main.async {
            appState.clearChatSession()
        }
    }
    
    private func startNewChatSession() {
        DispatchQueue.main.async {
            appState.startChatSession()
        }
    }
    
    private func selectQuickQuestion(_ question: String) {
        messageText = question
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sendMessage()
        }
    }
    
    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        // Stop any current TTS when sending a new message
        ttsService.stopSpeaking()
        
        let messageToSend = trimmedMessage
        messageText = ""
        isMessageFieldFocused = false
        
        // Send message asynchronously
        Task {
            await appState.sendMessage(messageToSend)
        }
    }
    
    private func getSuggestedQuestions() -> [String] {
        guard let userRole = appState.userRole else {
            return [
                "What are the main goals?",
                "What services are provided?",
                "What accommodations are included?"
            ]
        }
        
        switch userRole {
        case .parent:
            return [
                "How can I support at home?",
                "What should I ask at meetings?",
                "Is my child making progress?"
            ]
        case .teacher:
            return [
                "What accommodations should I implement?",
                "How do I track progress?",
                "What teaching strategies work best?"
            ]
        case .counselor:
            return [
                "What services are recommended?",
                "How can we improve coordination?",
                "What are the priority areas?"
            ]
        }
    }
    
    private func getSampleQuestions() -> [String] {
        return [
            "What are the main educational goals?",
            "What accommodations are recommended?",
            "How often is progress monitored?",
            "What services does the student receive?",
            "Are there any areas of concern?"
        ]
    }
}

// MARK: - Enhanced Message Bubble View with TTS
struct MessageBubbleView: View {
    let message: Message
    let ttsService: TTSService
    let isCurrentlyReading: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isFromUser {
                Spacer(minLength: 60)
            }
            
            HStack(alignment: .top, spacing: 8) {
                // Avatar
                if !message.isFromUser {
                    avatarView(isUser: false)
                }
                
                // Message Content
                VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                    // Message Bubble
                    VStack(alignment: .leading, spacing: 8) {
                        if message.messageType != .text {
                            // System/Error/Thinking message header
                            HStack(spacing: 4) {
                                if !message.messageType.icon.isEmpty {
                                    Image(systemName: message.messageType.icon)
                                        .font(.caption2)
                                        .foregroundColor(message.messageType.color)
                                }
                                
                                Text(message.messageType == .thinking ? "AI is thinking..." : "System")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(message.messageType.color)
                            }
                        }
                        
                        // Message text with TTS controls for AI responses
                        HStack(alignment: .top, spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                // Message content
                                if !message.isFromUser && message.messageType == .text {
                                    MarkdownText(message.text)
                                        .fixedSize(horizontal: false, vertical: true)
                                } else {
                                    Text(message.text)
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                // TTS controls for AI messages
                                if !message.isFromUser && message.messageType == .text {
                                    TTSMessageControls(
                                        message: message,
                                        ttsService: ttsService,
                                        isCurrentlyReading: isCurrentlyReading
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(backgroundColorForMessage(message))
                    .foregroundColor(foregroundColorForMessage(message))
                    .cornerRadius(16)
                    .overlay(
                        // Reading indicator border
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ColorTheme.primary, lineWidth: isCurrentlyReading ? 2 : 0)
                            .animation(.easeInOut(duration: 0.3), value: isCurrentlyReading)
                    )
                    
                    // Timestamp and Status
                    HStack(spacing: 4) {
                        Text(formatTime(message.timestamp))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if message.isFromUser && message.status != .received {
                            Image(systemName: message.status.icon)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                
                // User Avatar
                if message.isFromUser {
                    avatarView(isUser: true)
                }
            }
            
            if !message.isFromUser {
                Spacer(minLength: 60)
            }
        }
    }
    
    private func avatarView(isUser: Bool) -> some View {
        Circle()
            .fill(isUser ? ColorTheme.primary.opacity(0.1) : ColorTheme.info.opacity(0.1))
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: isUser ? "person.fill" : "brain.head.profile")
                    .font(.caption)
                    .foregroundColor(isUser ? ColorTheme.primary : ColorTheme.info)
            )
    }
    
    private func backgroundColorForMessage(_ message: Message) -> Color {
        if message.isFromUser {
            return ColorTheme.primary
        } else {
            switch message.messageType {
            case .text: return Color(.systemGray5)
            case .system: return ColorTheme.info.opacity(0.1)
            case .error: return ColorTheme.error.opacity(0.1)
            case .thinking: return ColorTheme.warning.opacity(0.1)
            }
        }
    }
    
    private func foregroundColorForMessage(_ message: Message) -> Color {
        if message.isFromUser {
            return .white
        } else {
            switch message.messageType {
            case .text: return .primary
            case .system: return ColorTheme.info
            case .error: return ColorTheme.error
            case .thinking: return ColorTheme.warning
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Markdown Text View (same as before)
struct MarkdownText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(parseMarkdownText(), id: \.id) { element in
                switch element.type {
                case .paragraph:
                    Text(processInlineMarkdown(element.content))
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                case .numberedList:
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(element.number ?? 1).")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(processInlineMarkdown(element.content))
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                case .bulletList:
                    HStack(alignment: .top, spacing: 8) {
                        Text("â€¢")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(processInlineMarkdown(element.content))
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
    
    private func parseMarkdownText() -> [MarkdownElement] {
        let lines = text.components(separatedBy: .newlines)
        var elements: [MarkdownElement] = []
        var currentParagraph = ""
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty {
                // Empty line - end current paragraph
                if !currentParagraph.isEmpty {
                    elements.append(MarkdownElement(type: .paragraph, content: currentParagraph.trimmingCharacters(in: .whitespaces)))
                    currentParagraph = ""
                }
                continue
            }
            
            // Check for numbered list (1. 2. etc.)
            if let match = trimmedLine.range(of: #"^\d+\.\s*(.+)$"#, options: .regularExpression) {
                // End current paragraph
                if !currentParagraph.isEmpty {
                    elements.append(MarkdownElement(type: .paragraph, content: currentParagraph.trimmingCharacters(in: .whitespaces)))
                    currentParagraph = ""
                }
                
                // Extract number and content
                let numberMatch = trimmedLine.range(of: #"^\d+"#, options: .regularExpression)
                let number = numberMatch != nil ? Int(String(trimmedLine[numberMatch!])) : 1
                let content = String(trimmedLine[match]).replacingOccurrences(of: #"^\d+\.\s*"#, with: "", options: .regularExpression)
                
                elements.append(MarkdownElement(type: .numberedList, content: content, number: number))
                continue
            }
            
            // Check for bullet list (- or *)
            if trimmedLine.hasPrefix("- ") || trimmedLine.hasPrefix("* ") {
                // End current paragraph
                if !currentParagraph.isEmpty {
                    elements.append(MarkdownElement(type: .paragraph, content: currentParagraph.trimmingCharacters(in: .whitespaces)))
                    currentParagraph = ""
                }
                
                let content = String(trimmedLine.dropFirst(2))
                elements.append(MarkdownElement(type: .bulletList, content: content))
                continue
            }
            
            // Regular line - add to current paragraph
            if !currentParagraph.isEmpty {
                currentParagraph += " "
            }
            currentParagraph += trimmedLine
        }
        
        // Add any remaining paragraph
        if !currentParagraph.isEmpty {
            elements.append(MarkdownElement(type: .paragraph, content: currentParagraph.trimmingCharacters(in: .whitespaces)))
        }
        
        return elements
    }
    
    private func processInlineMarkdown(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        // Process **bold** text
        let boldPattern = #"\*\*(.*?)\*\*"#
        if let regex = try? NSRegularExpression(pattern: boldPattern, options: []) {
            let nsString = text as NSString
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            var offset = 0
            for match in matches {
                let fullRange = match.range
                let contentRange = match.range(at: 1)
                
                if let fullSwiftRange = Range(fullRange, in: text),
                   let contentSwiftRange = Range(contentRange, in: text) {
                    
                    let adjustedFullRange = adjustRange(fullSwiftRange, offset: offset, in: attributedString)
                    let boldText = String(text[contentSwiftRange])
                    
                    // Replace the **text** with just text and make it bold
                    attributedString.replaceSubrange(adjustedFullRange, with: AttributedString(boldText))
                    
                    // Apply bold formatting
                    let newRange = adjustedFullRange.lowerBound..<attributedString.index(adjustedFullRange.lowerBound, offsetByCharacters: boldText.count)
                    attributedString[newRange].font = .subheadline.bold()
                    
                    // Update offset
                    offset += boldText.count - (fullRange.length)
                }
            }
        }
        
        return attributedString
    }
    
    private func adjustRange(_ range: Range<String.Index>, offset: Int, in attributedString: AttributedString) -> Range<AttributedString.Index> {
        let startIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: range.lowerBound.utf16Offset(in: text) + offset)
        let endIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: range.upperBound.utf16Offset(in: text) + offset)
        return startIndex..<endIndex
    }
}

// MARK: - Markdown Element Model
struct MarkdownElement: Identifiable {
    let id = UUID()
    let type: MarkdownType
    let content: String
    let number: Int?
    
    init(type: MarkdownType, content: String, number: Int? = nil) {
        self.type = type
        self.content = content
        self.number = number
    }
}

enum MarkdownType {
    case paragraph
    case numberedList
    case bulletList
}

// MARK: - Typing Indicator View
struct TypingIndicatorView: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // AI Avatar
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "brain.head.profile")
                        .font(.caption)
                        .foregroundColor(.blue)
                )
            
            // Typing Animation
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: animationPhase
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray5))
            .cornerRadius(16)
            
            Spacer(minLength: 60)
        }
        .onAppear {
            withAnimation {
                animationPhase = 1
            }
        }
    }
}

// MARK: - Preview
struct QAScreen_Previews: PreviewProvider {
    static var previews: some View {
        QAScreen()
            .environmentObject({
                let state = AppState()
                state.userRole = .parent
                state.isLoggedIn = true
                //state.loadSampleIEP()
                return state
            }())
    }
}
