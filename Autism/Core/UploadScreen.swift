//
//  UploadScreen.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct UploadScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var showingDocumentPicker = false
    @State private var draggedOver = false
    @State private var showingHelpSheet = false
    
    var body: some View {
        // FIXED: Removed NavigationView wrapper since this screen is already inside navigation
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Main Content
            ScrollView {
                VStack(spacing: 24) {
                    // FIXED: Show upload actions when there's no session OR session is in idle state
                    if let session = appState.uploadSession,
                       session.status != .idle {
                        // Active Upload Session (processing, analyzing, completed, failed)
                        activeUploadSection(session)
                    } else {
                        // Upload Introduction
                        uploadIntroSection
                        
                        // Upload Actions - FIXED: This will now show by default
                        uploadActionsSection
                        
                        // Document History
                        documentHistorySection
                    }
                    
                    // Help Section
                    helpSection
                }
                .padding(.horizontal, appState.isPad ? 32 : 20)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Upload Document")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingHelpSheet = true }) {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
        .fileImporter(
            isPresented: $showingDocumentPicker,
            allowedContentTypes: [.pdf, .plainText, .rtf],
            allowsMultipleSelection: false
        ) { result in
            handleDocumentSelection(result)
        }
        .sheet(isPresented: $showingHelpSheet) {
            UploadHelpSheet()
        }
        .alert("Upload Error", isPresented: $appState.showingErrorAlert) {
            Button("OK") {
                appState.clearError()
            }
        } message: {
            Text(appState.errorMessage ?? "An error occurred")
        }
        .onAppear {
            // FIXED: Only clear failed/completed sessions, don't interfere with normal flow
            if let session = appState.uploadSession {
                switch session.status {
                case .failed, .completed:
                    appState.cancelUploadSession()
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon and Title
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(.orange)
                }
                
                VStack(spacing: 4) {
                    Text("AI Document Analysis")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Upload an IEP or 504 plan for comprehensive insights")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Quick Stats
            if appState.hasDocumentHistory {
                HStack(spacing: 20) {
                    StatPill(
                        title: "Documents",
                        value: "\(appState.documentHistory.count)",
                        icon: "doc.fill",
                        color: .blue
                    )
                    
                    StatPill(
                        title: "Latest",
                        value: timeAgo(appState.documentHistory.last?.uploadDate ?? Date()),
                        icon: "clock.fill",
                        color: .green
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Upload Introduction
    private var uploadIntroSection: some View {
        VStack(spacing: 20) {
            // Feature Cards
            VStack(spacing: 16) {
                FeatureHighlight(
                    icon: "brain.head.profile",
                    title: "AI Analysis",
                    description: "Get comprehensive insights and recommendations",
                    color: .blue
                )
                
                FeatureHighlight(
                    icon: "message.fill",
                    title: "Ask Questions",
                    description: "Chat with AI about your document",
                    color: .green
                )
                
                FeatureHighlight(
                    icon: "chart.bar.fill",
                    title: "Progress Tracking",
                    description: "Monitor goals and track improvements",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Upload Actions (FIXED)
    private var uploadActionsSection: some View {
        VStack(spacing: 20) {
            // Primary Upload Button - FIXED - More prominent
            Button(action: {
                // FIXED: Start upload session when user taps the button
                appState.startUploadSession()
                showingDocumentPicker = true
            }) {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.orange.opacity(0.1))
                            .frame(height: 140)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                        
                        VStack(spacing: 16) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.orange)
                            
                            VStack(spacing: 4) {
                                Text("Select Document")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("Tap to browse files")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Supported formats
            VStack(spacing: 8) {
                Text("Supported file types:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    ForEach(["PDF", "DOC", "TXT"], id: \.self) { format in
                        Text(format)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                    }
                }
                
                Text("Maximum file size: 10 MB")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Active Upload Session (FIXED)
    private func activeUploadSection(_ session: UploadSession) -> some View {
        VStack(spacing: 20) {
            // Upload Progress
            uploadProgressCard(session)
            
            // Document Details
            if let document = session.selectedDocument {
                documentDetailsCard(document)
            }
            
            // Action Buttons
            uploadActionButtons(session)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Upload Progress Card
    private func uploadProgressCard(_ session: UploadSession) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(session.status.displayText)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if session.status == .processingDocument || session.status == .analyzingDocument {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            // Progress bar
            if session.status != .completed && session.status != .failed {
                ProgressView(value: appState.uploadProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
            }
            
            // Status message
            switch session.status {
            case .processingDocument:
                Text("Reading and processing your document...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
            case .analyzingDocument:
                Text("AI is analyzing your document for insights...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
            case .completed:
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Analysis complete!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                
            case .failed:
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Upload failed")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
                
            default:
                EmptyView()
            }
        }
    }
    
    // MARK: - Document Details Card
    private func documentDetailsCard(_ document: ProcessedDocument) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Document Details")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                DetailRow(label: "File", value: document.originalFileName)
                DetailRow(label: "Size", value: formatFileSize(document.fileSize))
                DetailRow(label: "Words", value: "\(document.wordCount)")
                if let pages = document.pageCount {
                    DetailRow(label: "Pages", value: "\(pages)")
                }
                DetailRow(label: "Type", value: document.fileType.displayName)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
    
    // MARK: - Upload Action Buttons
    private func uploadActionButtons(_ session: UploadSession) -> some View {
        VStack(spacing: 12) {
            switch session.status {
            case .completed:
                Button("View Analysis") {
                    appState.completeUploadSession()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Upload Another Document") {
                    appState.cancelUploadSession()
                }
                .buttonStyle(SecondaryButtonStyle())
                
            case .failed:
                if let error = session.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Button("Try Again") {
                    appState.startUploadSession()
                    showingDocumentPicker = true
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Cancel") {
                    appState.cancelUploadSession()
                }
                .buttonStyle(SecondaryButtonStyle())
                
            default:
                EmptyView()
            }
        }
    }
    
    // MARK: - Document History Section
    private var documentHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if appState.hasDocumentHistory {
                HStack {
                    Text("Recent Documents")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("View All") {
                        appState.navigate(to: .analysis)
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                }
                
                VStack(spacing: 12) {
                    ForEach(appState.documentHistory.prefix(3)) { document in
                        DocumentHistoryRow(document: document) {
                            appState.selectDocument(document)
                            appState.navigate(to: .analysis)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Help Section
    private var helpSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Need Help?")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                HelpCard(
                    icon: "doc.text",
                    title: "Supported Files",
                    description: "Upload PDF, Word, or text documents up to 10 MB"
                )
                
                HelpCard(
                    icon: "brain",
                    title: "AI Analysis",
                    description: "Our AI analyzes goals, services, and provides recommendations"
                )
                
                HelpCard(
                    icon: "shield",
                    title: "Privacy & Security",
                    description: "Your documents are processed securely and never stored permanently"
                )
            }
        }
    }
    
    // MARK: - Document Selection Handler (FIXED)
    private func handleDocumentSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                Task {
                    await appState.processSelectedDocument(url: url)
                }
            }
            
        case .failure(let error):
            Task {
                await appState.showError("Failed to select document: \(error.localizedDescription)")
            }
        }
        
        showingDocumentPicker = false
    }
    
    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Supporting Views

struct StatPill: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
}

struct FeatureHighlight: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(12)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct DocumentHistoryRow: View {
    let document: IEPData
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Document icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.blue)
                }
                
                // Document info
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.studentName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Uploaded \(timeAgo(document.uploadDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Quality score
                HStack(spacing: 4) {
                    Text("\(Int(document.qualityScore * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(qualityColor(document.qualityScore))
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.3))
            .cornerRadius(12)
        }
    }
    
    private func qualityColor(_ score: Double) -> Color {
        if score >= 0.8 { return .green }
        else if score >= 0.6 { return .orange }
        else { return .red }
    }
}

struct HelpCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(12)
    }
}

struct UploadHelpSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Upload Help")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Everything you need to know about uploading documents")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Supported Files
                    HelpSection(
                        title: "Supported File Types",
                        icon: "doc.text",
                        items: [
                            "PDF documents (.pdf)",
                            "Microsoft Word (.doc, .docx)",
                            "Plain text files (.txt)",
                            "Rich text files (.rtf)"
                        ]
                    )
                    
                    // File Requirements
                    HelpSection(
                        title: "File Requirements",
                        icon: "checkmark.shield",
                        items: [
                            "Maximum file size: 10 MB",
                            "Documents must be readable (not scanned images)",
                            "Text should be selectable in PDFs",
                            "No password-protected files"
                        ]
                    )
                    
                    // What Happens Next
                    HelpSection(
                        title: "What Happens After Upload",
                        icon: "gears",
                        items: [
                            "Document is processed and text extracted",
                            "AI analyzes goals, services, and assessments",
                            "Comprehensive report is generated",
                            "You can ask questions about your document"
                        ]
                    )
                    
                    // Privacy
                    HelpSection(
                        title: "Privacy & Security",
                        icon: "lock.shield",
                        items: [
                            "Documents are processed securely",
                            "No permanent storage of your files",
                            "All data is encrypted during processing",
                            "Analysis results are kept confidential"
                        ]
                    )
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HelpSection: View {
    let title: String
    let icon: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.orange)
                        
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Helper Functions

private func formatFileSize(_ bytes: Int) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useMB, .useKB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: Int64(bytes))
}

// MARK: - Preview
struct UploadScreen_Previews: PreviewProvider {
    static var previews: some View {
        UploadScreen()
            .environmentObject({
                let state = AppState()
                state.userRole = .teacher
                state.isLoggedIn = true
                return state
            }())
    }
}
