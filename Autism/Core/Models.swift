//
//  Models.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//  Updated by Rhea Sreedhar on 9/10/25 - Color Theme Integration
//

import SwiftUI
import Foundation

// MARK: - User Role
enum UserRole: String, CaseIterable {
    case parent = "parent"
    case teacher = "teacher"
    case counselor = "counselor"
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .parent: return "heart.fill"
        case .teacher: return "graduationcap.fill"
        case .counselor: return "person.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .parent: return ColorTheme.Role.parent        // Now Blue
        case .teacher: return ColorTheme.Role.teacher      // Now Purple
        case .counselor: return ColorTheme.Role.counselor  // Now Green
        }
    }
}

// MARK: - IEP Data Models
struct IEPData: Identifiable {
    // FIXED: Added id property and Identifiable conformance
    let id: UUID
    let studentName: String
    let fileName: String
    let uploadDate: Date
    let lastModified: Date
    let notes: String
    let overallScore: Int
    let qualityScore: Double
    let summary: String
    let strengths: [String]
    let concerns: [String]
    let recommendations: [String]
    let goals: [IEPGoal]
    let services: [IEPService]
    let documentId: UUID
    let originalDocument: ProcessedDocument?
    let analysisDate: Date
    
    init(
        studentName: String,
        fileName: String,
        uploadDate: Date,
        notes: String,
        overallScore: Int,
        summary: String,
        strengths: [String],
        concerns: [String],
        recommendations: [String],
        goals: [IEPGoal],
        services: [IEPService],
        documentId: UUID = UUID(),
        originalDocument: ProcessedDocument? = nil,
        analysisDate: Date = Date(),
        lastModified: Date = Date(),
        qualityScore: Double = 0.85,
        id: UUID = UUID()
    ) {
        self.id = id
        self.studentName = studentName
        self.fileName = fileName
        self.uploadDate = uploadDate
        self.lastModified = lastModified
        self.notes = notes
        self.overallScore = overallScore
        self.qualityScore = qualityScore  // FIXED: Added qualityScore assignment
        self.summary = summary
        self.strengths = strengths
        self.concerns = concerns
        self.recommendations = recommendations
        self.goals = goals
        self.services = services
        self.documentId = documentId
        self.originalDocument = originalDocument
        self.analysisDate = analysisDate
    }
}

struct IEPGoal {
    let area: String
    let goal: String
    let status: GoalStatus
    let progress: Int
    
    enum GoalStatus: String {
        case onTrack = "On Track"
        case needsAttention = "Needs Attention"
        case behind = "Behind"
        
        var color: Color {
            switch self {
            case .onTrack: return ColorTheme.success         // Green (unchanged)
            case .needsAttention: return ColorTheme.warning  // Orange (unchanged)
            case .behind: return ColorTheme.error            // Red (unchanged)
            }
        }
        
        var icon: String {
            switch self {
            case .onTrack: return "checkmark.circle.fill"
            case .needsAttention: return "clock.fill"
            case .behind: return "exclamationmark.triangle.fill"
            }
        }
    }
}

struct IEPService {
    let service: String
    let frequency: String
    let provider: String
}

// MARK: - Enhanced Message Model for Chat
struct Message: Identifiable, Equatable {
    let id: UUID
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    let messageType: MessageType
    let status: MessageStatus
    
    init(text: String, isFromUser: Bool, timestamp: Date = Date(), messageType: MessageType = .text, status: MessageStatus = .sent) {
        self.id = UUID()
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.messageType = messageType
        self.status = status
    }
    
    enum MessageType {
        case text
        case system
        case error
        case thinking
        
        var icon: String {
            switch self {
            case .text: return ""
            case .system: return "info.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            case .thinking: return "ellipsis.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .text: return ColorTheme.Text.primary        // System primary
            case .system: return ColorTheme.info              // Blue info
            case .error: return ColorTheme.error              // Red error
            case .thinking: return ColorTheme.warning         // Orange (unchanged for status)
            }
        }
    }
    
    enum MessageStatus {
        case sending
        case sent
        case failed
        case received
        
        var icon: String {
            switch self {
            case .sending: return "clock"
            case .sent: return "checkmark"
            case .failed: return "exclamationmark.circle"
            case .received: return "checkmark.circle"
            }
        }
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Document Upload Models
struct UploadSession: Identifiable {
    let id: UUID
    let startTime: Date
    var selectedDocument: ProcessedDocument?
    var analysisResult: IEPData?
    var chatHistory: [Message]
    var status: UploadStatus
    var errorMessage: String?
    
    init() {
        self.id = UUID()
        self.startTime = Date()
        self.chatHistory = []
        self.status = .idle
    }
    
    enum UploadStatus {
        case idle
        case selectingFile
        case processingDocument
        case analyzingDocument
        case completed
        case failed
        
        var displayText: String {
            switch self {
            case .idle: return "Ready to upload"
            case .selectingFile: return "Selecting document..."
            case .processingDocument: return "Processing document..."
            case .analyzingDocument: return "Analyzing with AI..."
            case .completed: return "Analysis complete"
            case .failed: return "Upload failed"
            }
        }
        
        var color: Color {
            switch self {
            case .idle: return ColorTheme.Text.secondary
            case .selectingFile, .processingDocument, .analyzingDocument: return ColorTheme.warning  // Orange for processing
            case .completed: return ColorTheme.success     // Green
            case .failed: return ColorTheme.error          // Red
            }
        }
        
        var showProgress: Bool {
            switch self {
            case .processingDocument, .analyzingDocument: return true
            default: return false
            }
        }
    }
}

// MARK: - Chat Session Model
struct ChatSession: Identifiable {
    let id: UUID
    let documentId: UUID
    let studentName: String
    let fileName: String
    var messages: [Message]
    let createdAt: Date
    var lastMessageAt: Date
    var isActive: Bool
    
    init(documentId: UUID, studentName: String, fileName: String) {
        self.id = UUID()
        self.documentId = documentId
        self.studentName = studentName
        self.fileName = fileName
        self.messages = []
        self.createdAt = Date()
        self.lastMessageAt = Date()
        self.isActive = true
        
        // Add welcome message
        let welcomeMessage = Message(
            text: "Hi! I'm here to help you understand \(studentName)'s document. What would you like to know?",
            isFromUser: false,
            messageType: .system
        )
        self.messages.append(welcomeMessage)
    }
    
    mutating func addMessage(_ message: Message) {
        messages.append(message)
        lastMessageAt = Date()
    }
    
    var messageCount: Int {
        return messages.filter { $0.messageType == .text }.count
    }
    
    var lastUserMessage: Message? {
        return messages.last { $0.isFromUser && $0.messageType == .text }
    }
    
    var lastAIMessage: Message? {
        return messages.last { !$0.isFromUser && $0.messageType == .text }
    }
}

// MARK: - File Upload Configuration
struct FileUploadConfig {
    static let supportedTypes = ["public.pdf", "public.plain-text", "public.rtf"]
    static let maxFileSize: Int = 10 * 1024 * 1024 // 10MB
    static let allowedExtensions = ["pdf", "txt", "rtf", "doc", "docx"]
    
    static var documentPickerTypes: [String] {
        return supportedTypes
    }
    
    static func isFileTypeSupported(_ fileExtension: String) -> Bool {
        return allowedExtensions.contains(fileExtension.lowercased())
    }
    
    static func getDisplayName(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "pdf": return "PDF Document"
        case "txt": return "Text File"
        case "rtf": return "Rich Text Document"
        case "doc", "docx": return "Word Document"
        default: return "Document"
        }
    }
}

// MARK: - App State Extensions for Document Management
extension IEPData {
    // Helper to extract student name from document content or filename
    static func extractStudentName(from text: String, fileName: String) -> String {
        // Try to find student name patterns in the text
        let patterns = [
            "Student:?\\s*([A-Z][a-z]+(?:\\s+[A-Z][a-z]+)*)",
            "Name:?\\s*([A-Z][a-z]+(?:\\s+[A-Z][a-z]+)*)",
            "Child:?\\s*([A-Z][a-z]+(?:\\s+[A-Z][a-z]+)*)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
               let range = Range(match.range(at: 1), in: text) {
                let name = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                if name.count > 1 && name.count < 50 {
                    return name
                }
            }
        }
        
        // Fallback to filename-based extraction
        let cleanFileName = fileName
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
        
        let fileComponents = cleanFileName.components(separatedBy: " ")
        for component in fileComponents {
            if component.count > 2 && component.first?.isUppercase == true {
                return component
            }
        }
        
        // Default fallback
        return "Student"
    }
}

// MARK: - Enhanced Data Models for Assessment (Existing, preserved)
struct AssessmentDomain {
    let id: UUID
    let title: String
    let icon: String
    let color: Color
    let areas: [AssessmentArea]
    let overallProgress: Double
    
    init(title: String, icon: String, color: Color, areas: [AssessmentArea], overallProgress: Double) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.color = color
        self.areas = areas
        self.overallProgress = overallProgress
    }
}

struct AssessmentArea: Identifiable {
    let id: UUID
    let title: String
    let baseline: String
    let progress: String
    let challenges: String
    let metrics: [Metric]
    let overallScore: AssessmentLevel
    
    init(title: String, baseline: String, progress: String, challenges: String, metrics: [Metric], overallScore: AssessmentLevel) {
        self.id = UUID()
        self.title = title
        self.baseline = baseline
        self.progress = progress
        self.challenges = challenges
        self.metrics = metrics
        self.overallScore = overallScore
    }
}

struct Metric {
    let name: String
    let value: String
    let type: MetricType
    let level: AssessmentLevel
}

enum MetricType {
    case percentage
    case score
    case qualitative
    case wpm
}

enum AssessmentLevel: String, CaseIterable {
    case veryLow = "Very Low"
    case low = "Low"
    case belowAverage = "Below Average"
    case average = "Average"
    case aboveAverage = "Above Average"
    case proficient = "Proficient"
    case instructional = "Instructional"
    case veryElevated = "Very Elevated"
    case elevated = "Elevated"
    
    var color: Color {
        switch self {
        case .veryLow, .low: return ColorTheme.error           // Red
        case .belowAverage: return ColorTheme.warning          // Orange
        case .average, .instructional: return Color.yellow     // Yellow (unchanged)
        case .aboveAverage, .proficient: return ColorTheme.success  // Green
        case .elevated, .veryElevated: return Color.purple     // Purple (unchanged)
        }
    }
    
    var progressValue: Double {
        switch self {
        case .veryLow: return 0.1
        case .low: return 0.25
        case .belowAverage: return 0.4
        case .average, .instructional: return 0.6
        case .aboveAverage, .proficient: return 0.8
        case .elevated, .veryElevated: return 0.9
        }
    }
}

// MARK: - Enhanced Service Models (Existing, preserved)
struct ServiceCategory {
    let id: UUID
    let title: String
    let icon: String
    let color: Color
    let currentServices: [CurrentService]
    let additionalNeeds: [AdditionalNeed]
    let overallStatus: ServiceStatus
    
    init(title: String, icon: String, color: Color, currentServices: [CurrentService], additionalNeeds: [AdditionalNeed], overallStatus: ServiceStatus) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.color = color
        self.currentServices = currentServices
        self.additionalNeeds = additionalNeeds
        self.overallStatus = overallStatus
    }
}

struct CurrentService {
    let id: UUID
    let name: String
    let frequency: String
    let duration: String
    let location: String
    let weeklyMinutes: Int
    let yearlyMinutes: Int?
    let provider: String
    let status: ServiceStatus
    
    init(name: String, frequency: String, duration: String, location: String, weeklyMinutes: Int, yearlyMinutes: Int?, provider: String, status: ServiceStatus) {
        self.id = UUID()
        self.name = name
        self.frequency = frequency
        self.duration = duration
        self.location = location
        self.weeklyMinutes = weeklyMinutes
        self.yearlyMinutes = yearlyMinutes
        self.provider = provider
        self.status = status
    }
}

struct AdditionalNeed {
    let id: UUID
    let area: String
    let description: String
    let strategies: [String]
    let priority: Priority
    let status: ServiceStatus
    
    init(area: String, description: String, strategies: [String], priority: Priority, status: ServiceStatus) {
        self.id = UUID()
        self.area = area
        self.description = description
        self.strategies = strategies
        self.priority = priority
        self.status = status
    }
}

enum ServiceStatus: String, CaseIterable {
    case current = "Currently Provided"
    case needed = "Additional Need"
    case adequate = "Adequate"
    case insufficient = "Needs Increase"
    case excellent = "Excellent"
    
    var color: Color {
        switch self {
        case .current, .excellent: return ColorTheme.success     // Green
        case .adequate: return ColorTheme.info                   // Blue
        case .needed, .insufficient: return ColorTheme.warning   // Orange
        }
    }
    
    var icon: String {
        switch self {
        case .current, .excellent: return "checkmark.circle.fill"
        case .adequate: return "info.circle.fill"
        case .needed, .insufficient: return "plus.circle.fill"
        }
    }
}

enum Priority: String, CaseIterable {
    case high = "High Priority"
    case medium = "Medium Priority"
    case low = "Low Priority"
    
    var color: Color {
        switch self {
        case .high: return ColorTheme.error       // Red
        case .medium: return ColorTheme.warning   // Orange
        case .low: return ColorTheme.success      // Green
        }
    }
}

// Helper function for date formatting
func timeAgo(_ date: Date) -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: date, relativeTo: Date())
}
