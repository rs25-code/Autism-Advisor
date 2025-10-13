//
//  DocumentProcessor.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import Foundation
import PDFKit
import UniformTypeIdentifiers

// MARK: - Document Processing Errors
enum DocumentProcessingError: LocalizedError {
    case unsupportedFileType
    case fileTooLarge
    case fileNotFound
    case emptyDocument
    case corruptedFile
    case extractionFailed
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFileType:
            return "This file type is not supported. Please select a PDF, DOC, DOCX, or TXT file."
        case .fileTooLarge:
            return "File is too large. Please select a file smaller than 10MB."
        case .fileNotFound:
            return "The selected file could not be found."
        case .emptyDocument:
            return "The document appears to be empty or contains no readable text."
        case .corruptedFile:
            return "The file appears to be corrupted and cannot be read."
        case .extractionFailed:
            return "Failed to extract text from the document. Please try a different file."
        case .permissionDenied:
            return "Permission denied. Please ensure the file is accessible."
        }
    }
}

// MARK: - Processed Document
struct ProcessedDocument {
    let originalFileName: String
    let fileSize: Int
    let pageCount: Int?
    let extractedText: String
    let wordCount: Int
    let processingDate: Date
    let fileType: DocumentType
    
    var summary: String {
        var parts: [String] = []
        parts.append("\(wordCount) words")
        
        if let pages = pageCount {
            parts.append("\(pages) pages")
        }
        
        parts.append(fileType.displayName)
        
        return parts.joined(separator: " • ")
    }
}

// MARK: - Document Types
enum DocumentType: CaseIterable {
    case pdf
    case docx
    case doc
    case txt
    case rtf
    
    var displayName: String {
        switch self {
        case .pdf: return "PDF"
        case .docx: return "Word Document"
        case .doc: return "Word Document (Legacy)"
        case .txt: return "Text File"
        case .rtf: return "Rich Text"
        }
    }
    
    var supportedExtensions: [String] {
        switch self {
        case .pdf: return ["pdf"]
        case .docx: return ["docx"]
        case .doc: return ["doc"]
        case .txt: return ["txt"]
        case .rtf: return ["rtf"]
        }
    }
    
    var utType: UTType {
        switch self {
        case .pdf: return .pdf
        case .docx: return UTType(filenameExtension: "docx") ?? .data
        case .doc: return UTType(filenameExtension: "doc") ?? .data
        case .txt: return .plainText
        case .rtf: return .rtf
        }
    }
    
    static var allUTTypes: [UTType] {
        return DocumentType.allCases.map { $0.utType }
    }
}

// MARK: - Document Processor
@MainActor
class DocumentProcessor: ObservableObject {
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0.0
    @Published var lastError: DocumentProcessingError?
    @Published var currentDocument: ProcessedDocument?
    
    // Configuration
    private let maxFileSize: Int = 10 * 1024 * 1024 // 10MB
    private let maxWordCount: Int = 50000 // Reasonable limit for API calls
    
    // MARK: - Public Methods
    func processDocument(from url: URL) async throws -> ProcessedDocument {
        isProcessing = true
        processingProgress = 0.0
        lastError = nil
        
        defer {
            Task { @MainActor in
                isProcessing = false
                processingProgress = 0.0
            }
        }
        
        do {
            // Step 1: Validate file access and security
            await updateProgress(0.1)
            try validateFileAccess(url)
            
            // Step 2: Check file size and type
            await updateProgress(0.2)
            let fileType = try determineFileType(from: url)
            try validateFileSize(url)
            
            // Step 3: Extract text based on file type
            await updateProgress(0.3)
            let extractedText = try await extractText(from: url, type: fileType)
            
            // Step 4: Validate and clean text
            await updateProgress(0.7)
            let cleanedText = try validateAndCleanText(extractedText)
            
            // Step 5: Create processed document
            await updateProgress(0.9)
            let document = try createProcessedDocument(
                from: url,
                text: cleanedText,
                fileType: fileType
            )
            
            await updateProgress(1.0)
            
            await MainActor.run {
                currentDocument = document
            }
            
            print("✅ Document processed successfully: \(document.originalFileName)")
            return document
            
        } catch let error as DocumentProcessingError {
            await MainActor.run {
                lastError = error
            }
            print("❌ Document processing failed: \(error.localizedDescription)")
            throw error
        } catch {
            let processingError = DocumentProcessingError.extractionFailed
            await MainActor.run {
                lastError = processingError
            }
            print("❌ Unexpected error: \(error)")
            throw processingError
        }
    }
    
    func clearCurrentDocument() {
        currentDocument = nil
        lastError = nil
    }
    
    // MARK: - Private Methods
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            processingProgress = progress
        }
    }
    
    private func validateFileAccess(_ url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw DocumentProcessingError.permissionDenied
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DocumentProcessingError.fileNotFound
        }
    }
    
    private func determineFileType(from url: URL) throws -> DocumentType {
        let fileExtension = url.pathExtension.lowercased()
        
        for documentType in DocumentType.allCases {
            if documentType.supportedExtensions.contains(fileExtension) {
                return documentType
            }
        }
        
        throw DocumentProcessingError.unsupportedFileType
    }
    
    private func validateFileSize(_ url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw DocumentProcessingError.permissionDenied
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = fileAttributes[.size] as? Int ?? 0
            
            if fileSize > maxFileSize {
                throw DocumentProcessingError.fileTooLarge
            }
        } catch {
            throw DocumentProcessingError.fileNotFound
        }
    }
    
    private func extractText(from url: URL, type: DocumentType) async throws -> String {
        guard url.startAccessingSecurityScopedResource() else {
            throw DocumentProcessingError.permissionDenied
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        switch type {
        case .pdf:
            return try extractTextFromPDF(url)
        case .txt:
            return try extractTextFromTXT(url)
        case .rtf:
            return try extractTextFromRTF(url)
        case .docx, .doc:
            // For Word documents, we'll try to extract as plain text
            // In a production app, you might want to use a dedicated library
            return try extractTextFromWordDocument(url)
        }
    }
    
    private func extractTextFromPDF(_ url: URL) throws -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw DocumentProcessingError.corruptedFile
        }
        
        let pageCount = pdfDocument.pageCount
        guard pageCount > 0 else {
            throw DocumentProcessingError.emptyDocument
        }
        
        var extractedText = ""
        
        for pageIndex in 0..<pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            
            if let pageText = page.string {
                extractedText += pageText + "\n\n"
            }
            
            // Update progress for each page
            let progress = 0.3 + (Double(pageIndex + 1) / Double(pageCount)) * 0.4
            Task { await updateProgress(progress) }
        }
        
        return extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func extractTextFromTXT(_ url: URL) throws -> String {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            // Try other encodings
            do {
                let content = try String(contentsOf: url, encoding: .ascii)
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                throw DocumentProcessingError.extractionFailed
            }
        }
    }
    
    private func extractTextFromRTF(_ url: URL) throws -> String {
        do {
            let attributedString = try NSAttributedString(
                url: url,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil
            )
            return attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            throw DocumentProcessingError.extractionFailed
        }
    }
    
    private func extractTextFromWordDocument(_ url: URL) throws -> String {
        // For Word documents, we'll attempt to read as RTF first, then fall back to basic methods
        // In a production app, consider using a dedicated library like SwiftDocx
        
        do {
            // Try reading as RTF (some .doc files can be read this way)
            let attributedString = try NSAttributedString(
                url: url,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil
            )
            return attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            // If RTF reading fails, provide a helpful message
            throw DocumentProcessingError.unsupportedFileType
        }
    }
    
    private func validateAndCleanText(_ text: String) throws -> String {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedText.isEmpty else {
            throw DocumentProcessingError.emptyDocument
        }
        
        // Count words
        let wordCount = trimmedText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }.count
        
        guard wordCount <= maxWordCount else {
            // Truncate if too long
            let words = trimmedText.components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }
            let truncatedWords = Array(words.prefix(maxWordCount))
            return truncatedWords.joined(separator: " ")
        }
        
        // Clean up excessive whitespace and normalize line breaks
        let cleanedText = trimmedText
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
            .replacingOccurrences(of: " {2,}", with: " ", options: .regularExpression)
        
        return cleanedText
    }
    
    private func createProcessedDocument(from url: URL, text: String, fileType: DocumentType) throws -> ProcessedDocument {
        guard url.startAccessingSecurityScopedResource() else {
            throw DocumentProcessingError.permissionDenied
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        let fileName = url.lastPathComponent
        let fileAttributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = fileAttributes?[.size] as? Int ?? 0
        
        let wordCount = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }.count
        
        // Calculate page count for PDFs
        var pageCount: Int? = nil
        if fileType == .pdf, let pdfDocument = PDFDocument(url: url) {
            pageCount = pdfDocument.pageCount
        }
        
        return ProcessedDocument(
            originalFileName: fileName,
            fileSize: fileSize,
            pageCount: pageCount,
            extractedText: text,
            wordCount: wordCount,
            processingDate: Date(),
            fileType: fileType
        )
    }
}

// MARK: - Extensions
extension DocumentProcessor {
    var supportedFileTypes: [String] {
        return DocumentType.allCases.flatMap { $0.supportedExtensions }
    }
    
    var supportedFileTypesDisplay: String {
        return supportedFileTypes.map { ".\($0)" }.joined(separator: ", ")
    }
}
