//
//  GoalsTabView.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//
import SwiftUI

struct GoalsTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var expandedDomains: Set<UUID> = []
    @State private var selectedArea: AssessmentArea?
    @State private var showingInsights = false
    
    private let assessmentDomains: [AssessmentDomain] = [
        AssessmentDomain(
            title: "Academic Progress",
            icon: "graduationcap.fill",
            color: .blue,
            areas: [
                AssessmentArea(
                    title: "Reading",
                    baseline: "Independent: 2nd Grade, Instructional: 3rd Grade, WPM: 66, Accuracy: 25%, Comprehension: 20%",
                    progress: "Working on grade-level materials with support",
                    challenges: "Improve accuracy and comprehension at 3rd-4th grade levels. Reduce reliance on help-seeking.",
                    metrics: [
                        Metric(name: "WPM (3rd Grade)", value: "66", type: .wpm, level: .belowAverage),
                        Metric(name: "Accuracy (4th Grade)", value: "25%", type: .percentage, level: .veryLow),
                        Metric(name: "Comprehension", value: "20%", type: .percentage, level: .veryLow)
                    ],
                    overallScore: .low
                ),
                AssessmentArea(
                    title: "Writing",
                    baseline: "Capitalization: 80%, Sentences/day: 5, Typing: 16.8 WPM alphabet, 11.2 WPM sentences",
                    progress: "Can write on Chromebook using model and dictation. Typing faster than paper/pencil.",
                    challenges: "Generalizing verb tense, maintaining alignment, writing from memory",
                    metrics: [
                        Metric(name: "Capitalization & Punctuation", value: "80%", type: .percentage, level: .aboveAverage),
                        Metric(name: "Typing Speed (Alphabet)", value: "16.8 WPM", type: .wpm, level: .average),
                        Metric(name: "Written Language Clusters", value: "Very Low", type: .qualitative, level: .veryLow)
                    ],
                    overallScore: .belowAverage
                ),
                AssessmentArea(
                    title: "Mathematics",
                    baseline: "Addition/Subtraction: Proficient, Multiplication: 100% accuracy, Most concepts: Proficient/Instructional",
                    progress: "Strong in basic operations and most benchmark concepts",
                    challenges: "Two-step multiplication word problems: 20% accuracy",
                    metrics: [
                        Metric(name: "Basic Operations", value: "100%", type: .percentage, level: .proficient),
                        Metric(name: "Two-step Problems", value: "20%", type: .percentage, level: .veryLow),
                        Metric(name: "Math Calculation", value: "Average", type: .qualitative, level: .average)
                    ],
                    overallScore: .average
                )
            ],
            overallProgress: 0.45
        ),
        AssessmentDomain(
            title: "Communication Progress",
            icon: "message.fill",
            color: .green,
            areas: [
                AssessmentArea(
                    title: "Oral Production & Articulation",
                    baseline: "Oral production, voice, fluency, and articulation within normal limits",
                    progress: "No concerns in this area",
                    challenges: "Continue monitoring",
                    metrics: [
                        Metric(name: "Oral Production", value: "Normal", type: .qualitative, level: .average),
                        Metric(name: "Articulation", value: "Normal", type: .qualitative, level: .average)
                    ],
                    overallScore: .average
                ),
                AssessmentArea(
                    title: "Receptive & Expressive Language",
                    baseline: "EOWPVT & ROWPVT: Below Average, WH questions: 12/30 correct",
                    progress: "Functional language adequate for describing scenes",
                    challenges: "Significant delays in vocabulary, inconsistent tense/pronoun use",
                    metrics: [
                        Metric(name: "Vocabulary Skills", value: "Below Average", type: .qualitative, level: .belowAverage),
                        Metric(name: "WH Questions", value: "40%", type: .percentage, level: .low),
                        Metric(name: "Scene Description", value: "Functional", type: .qualitative, level: .average)
                    ],
                    overallScore: .belowAverage
                ),
                AssessmentArea(
                    title: "Pragmatic Language",
                    baseline: "CASL-2: Well Below Average, ASRS Social Communication: Very Elevated (T-scores: 72-81)",
                    progress: "Appropriate greetings, body language, responding to emotions",
                    challenges: "Difficulty in group activities, limited peer interaction",
                    metrics: [
                        Metric(name: "Social Greetings", value: "Yes", type: .qualitative, level: .average),
                        Metric(name: "CASL-2 Pragmatics", value: "Well Below Average", type: .qualitative, level: .veryLow),
                        Metric(name: "Group Participation", value: "Limited", type: .qualitative, level: .low)
                    ],
                    overallScore: .low
                )
            ],
            overallProgress: 0.35
        ),
        AssessmentDomain(
            title: "Social Emotional & Behavioral",
            icon: "heart.fill",
            color: .pink,
            areas: [
                AssessmentArea(
                    title: "Emotional Regulation",
                    baseline: "Regulates with staff assistance: 70%, Asks for help: 30%",
                    progress: "Participates daily, expresses emotions, reduced negative behaviors",
                    challenges: "Increase independent regulation and help-seeking",
                    metrics: [
                        Metric(name: "Regulation with Support", value: "70%", type: .percentage, level: .average),
                        Metric(name: "Independent Help-Seeking", value: "30%", type: .percentage, level: .low),
                        Metric(name: "Daily Participation", value: "Yes", type: .qualitative, level: .proficient)
                    ],
                    overallScore: .average
                ),
                AssessmentArea(
                    title: "Sensory Processing",
                    baseline: "Sensory Profile 2: 'More Than Others' or 'Very Elevated' across all sections",
                    progress: "Benefits from movement breaks, fidgets, noise-cancellation headphones",
                    challenges: "Sensitivity to loud noises, toilet flushing",
                    metrics: [
                        Metric(name: "Sensory Sensitivity", value: "Very Elevated", type: .qualitative, level: .veryElevated),
                        Metric(name: "Regulation Tools", value: "Helpful", type: .qualitative, level: .proficient),
                        Metric(name: "Noise Tolerance", value: "Low", type: .qualitative, level: .low)
                    ],
                    overallScore: .elevated
                ),
                AssessmentArea(
                    title: "Self-Regulation & Attention",
                    baseline: "ASRS Self-Regulation: Elevated, Conners 3 Inattention: Very Elevated",
                    progress: "Can quiet with increased attention, engages in math games",
                    challenges: "Difficulty focusing, easily distracted, needs verbal prompts",
                    metrics: [
                        Metric(name: "Self-Regulation", value: "Elevated", type: .qualitative, level: .elevated),
                        Metric(name: "Attention Span", value: "Limited", type: .qualitative, level: .low),
                        Metric(name: "Task Engagement", value: "With Support", type: .qualitative, level: .average)
                    ],
                    overallScore: .belowAverage
                )
            ],
            overallProgress: 0.5
        ),
        AssessmentDomain(
            title: "Motor Skills",
            icon: "figure.run",
            color: .orange,
            areas: [
                AssessmentArea(
                    title: "Fine Motor",
                    baseline: "BOT-2 Fine Motor Control: Below Average",
                    progress: "Strengths in connecting dots, copying shapes, bilateral hand use",
                    challenges: "Precision, speed, endurance for pencil control and cutting",
                    metrics: [
                        Metric(name: "Fine Motor Control", value: "Below Average", type: .qualitative, level: .belowAverage),
                        Metric(name: "Shape Copying", value: "Good", type: .qualitative, level: .average),
                        Metric(name: "Cutting Precision", value: "Needs Work", type: .qualitative, level: .low)
                    ],
                    overallScore: .belowAverage
                ),
                AssessmentArea(
                    title: "Visual Motor & Perceptual",
                    baseline: "Drawing: Significantly Below Average (1st percentile), Matching: Average",
                    progress: "Correctly draws 8 shapes, recognizes items with orientation changes",
                    challenges: "Visual-motor integration significantly delayed",
                    metrics: [
                        Metric(name: "Visual-Motor Drawing", value: "1st Percentile", type: .qualitative, level: .veryLow),
                        Metric(name: "Visual-Spatial Matching", value: "Average", type: .qualitative, level: .average),
                        Metric(name: "Shape Recognition", value: "8/10", type: .score, level: .average)
                    ],
                    overallScore: .low
                )
            ],
            overallProgress: 0.3
        ),
        AssessmentDomain(
            title: "Daily Living & Vocational",
            icon: "house.fill",
            color: .purple,
            areas: [
                AssessmentArea(
                    title: "Daily Living Skills",
                    baseline: "Independent: lunch, putting away items, restroom, dressing for PE",
                    progress: "Strong independence in most daily activities",
                    challenges: "Requires assistance with hygiene",
                    metrics: [
                        Metric(name: "Lunch Management", value: "Independent", type: .qualitative, level: .proficient),
                        Metric(name: "Restroom Use", value: "Independent", type: .qualitative, level: .proficient),
                        Metric(name: "Hygiene", value: "Needs Support", type: .qualitative, level: .low)
                    ],
                    overallScore: .average
                ),
                AssessmentArea(
                    title: "Vocational Skills",
                    baseline: "Minimal prompting for routines, independent with technology",
                    progress: "Follows routines, uses Chromebook, knows schedule, handles money/time",
                    challenges: "Continue building independence",
                    metrics: [
                        Metric(name: "Routine Following", value: "Minimal Prompts", type: .qualitative, level: .proficient),
                        Metric(name: "Technology Use", value: "Independent", type: .qualitative, level: .proficient),
                        Metric(name: "Money Skills", value: "Good", type: .qualitative, level: .average)
                    ],
                    overallScore: .average
                )
            ],
            overallProgress: 0.7
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with AI Insights
                headerSection
                
                // Domain Cards
                VStack(spacing: 16) {
                    ForEach(assessmentDomains, id: \.id) { domain in
                        DomainCard(
                            domain: domain,
                            isExpanded: expandedDomains.contains(domain.id)
                        ) {
                            toggleDomain(domain.id)
                        } onAreaTap: { area in
                            selectedArea = area
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(item: $selectedArea) { area in
            DetailedAreaView(area: area)
        }
        .sheet(isPresented: $showingInsights) {
            AIInsightsView()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Assessment Overview")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Comprehensive progress across all domains")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: { showingInsights = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "brain.head.profile")
                        Text("AI Insights")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
            }
            
            // Overall Progress Summary
            HStack(spacing: 20) {
                ForEach(assessmentDomains.prefix(3), id: \.id) { domain in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(domain.color.opacity(0.2), lineWidth: 6)
                                .frame(width: 50, height: 50)
                            
                            Circle()
                                .trim(from: 0, to: domain.overallProgress)
                                .stroke(domain.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.5), value: domain.overallProgress)
                            
                            Text("\(Int(domain.overallProgress * 100))%")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        
                        Text(domain.title.components(separatedBy: " ").first ?? "")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
    
    private func toggleDomain(_ domainId: UUID) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if expandedDomains.contains(domainId) {
                expandedDomains.remove(domainId)
            } else {
                expandedDomains.insert(domainId)
            }
        }
    }
}

// MARK: - Domain Card Component
struct DomainCard: View {
    let domain: AssessmentDomain
    let isExpanded: Bool
    let onToggle: () -> Void
    let onAreaTap: (AssessmentArea) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Domain Header
            Button(action: onToggle) {
                HStack(spacing: 16) {
                    // Icon and Progress Ring
                    ZStack {
                        Circle()
                            .stroke(domain.color.opacity(0.2), lineWidth: 8)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: domain.overallProgress)
                            .stroke(domain.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.5), value: domain.overallProgress)
                        
                        Image(systemName: domain.icon)
                            .font(.title2)
                            .foregroundColor(domain.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(domain.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("\(domain.areas.count) assessment areas")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(domain.overallProgress * 100))% overall progress")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(domain.color.opacity(0.1))
                            .foregroundColor(domain.color)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.title3)
                        .foregroundColor(domain.color)
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
                .padding()
            }
            
            // Expandable Content
            if isExpanded {
                VStack(spacing: 12) {
                    Divider()
                        .background(domain.color.opacity(0.3))
                    
                    ForEach(domain.areas, id: \.id) { area in
                        AreaSummaryCard(area: area, domainColor: domain.color) {
                            onAreaTap(area)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(domain.color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Area Summary Card
struct AreaSummaryCard: View {
    let area: AssessmentArea
    let domainColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(area.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Overall: \(area.overallScore.rawValue)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(area.overallScore.color.opacity(0.1))
                            .foregroundColor(area.overallScore.color)
                            .cornerRadius(6)
                    }
                    
                    Spacer()
                    
                    // Progress indicator
                    ZStack {
                        Circle()
                            .stroke(area.overallScore.color.opacity(0.2), lineWidth: 4)
                            .frame(width: 30, height: 30)
                        
                        Circle()
                            .trim(from: 0, to: area.overallScore.progressValue)
                            .stroke(area.overallScore.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 30, height: 30)
                            .rotationEffect(.degrees(-90))
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Three-column summary
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Baseline")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        Text(String(area.baseline.prefix(50)) + (area.baseline.count > 50 ? "..." : ""))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 1, height: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Progress")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                        Text(String(area.progress.prefix(50)) + (area.progress.count > 50 ? "..." : ""))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 1, height: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Focus Areas")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                        Text(String(area.challenges.prefix(50)) + (area.challenges.count > 50 ? "..." : ""))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(12)
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(12)
        }
    }
}

// MARK: - Detailed Area View
struct DetailedAreaView: View {
    let area: AssessmentArea
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with overall score
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(area.overallScore.color.opacity(0.2), lineWidth: 12)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: area.overallScore.progressValue)
                                .stroke(area.overallScore.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 2), value: area.overallScore.progressValue)
                            
                            VStack {
                                Text("\(Int(area.overallScore.progressValue * 100))%")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text(area.overallScore.rawValue)
                                    .font(.caption)
                                    .foregroundColor(area.overallScore.color)
                            }
                        }
                        
                        Text(area.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    // FIXED: Metrics Grid with proper layout
                    if !area.metrics.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Key Metrics")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            // FIXED: Proper grid layout for metrics
                            let metricsCount = area.metrics.count
                            if metricsCount % 2 == 1 && metricsCount > 1 {
                                // Handle odd number of metrics with last one spanning full width
                                VStack(spacing: 12) {
                                    // First rows with pairs
                                    ForEach(0..<(metricsCount - 1)/2, id: \.self) { row in
                                        HStack(spacing: 12) {
                                            MetricCard(metric: area.metrics[row * 2])
                                            MetricCard(metric: area.metrics[row * 2 + 1])
                                        }
                                    }
                                    // Last single metric spanning full width
                                    MetricCard(metric: area.metrics[metricsCount - 1])
                                        .frame(maxWidth: .infinity)
                                }
                            } else {
                                // Even number or single metric
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: metricsCount == 1 ? 1 : 2), spacing: 12) {
                                    ForEach(area.metrics, id: \.name) { metric in
                                        MetricCard(metric: metric)
                                    }
                                }
                            }
                        }
                    }
                    
                    // FIXED: Three-column detailed view with equal width
                    VStack(spacing: 20) {
                        DetailSection(
                            title: "Current Level/Baseline",
                            content: area.baseline,
                            color: .blue,
                            icon: "chart.line.uptrend.xyaxis"
                        )
                        
                        DetailSection(
                            title: "Progress & Strengths",
                            content: area.progress,
                            color: .green,
                            icon: "checkmark.circle.fill"
                        )
                        
                        DetailSection(
                            title: "Areas for Continued Focus",
                            content: area.challenges,
                            color: .orange,
                            icon: "target"
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(area.title)
            .navigationBarTitleDisplayMode(.large)
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

// MARK: - Supporting Views
struct MetricCard: View {
    let metric: Metric
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(metric.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            
            HStack {
                Text(metric.value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(metric.level.color)
                    .lineLimit(1)
                Spacer()
                
                Circle()
                    .fill(metric.level.color)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct DetailSection: View {
    let title: String
    let content: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct AIInsightsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Cross-domain insights
                    InsightCard(
                        title: "Cross-Domain Connection",
                        insight: "Fine motor challenges (Below Average) may be impacting writing performance. Consider OT collaboration for writing goals.",
                        type: .connection,
                        priority: .medium
                    )
                    
                    InsightCard(
                        title: "Strength to Leverage",
                        insight: "Strong math skills (100% multiplication accuracy) could be used to build confidence while addressing reading challenges.",
                        type: .strength,
                        priority: .high
                    )
                    
                    InsightCard(
                        title: "Priority Focus Area",
                        insight: "Pragmatic language skills show significant delays. Consider increasing social skills intervention frequency.",
                        type: .concern,
                        priority: .high
                    )
                    
                    InsightCard(
                        title: "Positive Trend",
                        insight: "Emotional regulation has improved with consistent support strategies. Continue current approach.",
                        type: .trend,
                        priority: .low
                    )
                }
                .padding()
            }
            .navigationTitle("AI Insights")
            .navigationBarTitleDisplayMode(.large)
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

struct InsightCard: View {
    let title: String
    let insight: String
    let type: InsightType
    let priority: Priority
    
    enum InsightType {
        case connection, strength, concern, trend
        
        var icon: String {
            switch self {
            case .connection: return "arrow.triangle.branch"
            case .strength: return "star.fill"
            case .concern: return "exclamationmark.triangle.fill"
            case .trend: return "chart.line.uptrend.xyaxis"
            }
        }
        
        var color: Color {
            switch self {
            case .connection: return .blue
            case .strength: return .green
            case .concern: return .orange
            case .trend: return .purple
            }
        }
    }
    
    enum Priority {
        case high, medium, low
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .green
            }
        }
        
        var text: String {
            switch self {
            case .high: return "High Priority"
            case .medium: return "Medium Priority"
            case .low: return "Low Priority"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: type.icon)
                        .font(.title3)
                        .foregroundColor(type.color)
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Text(priority.text)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priority.color.opacity(0.1))
                    .foregroundColor(priority.color)
                    .cornerRadius(8)
            }
            
            Text(insight)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Button("View Details") {
                    // Handle view details
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(type.color.opacity(0.1))
                .foregroundColor(type.color)
                .cornerRadius(8)
                
                Spacer()
                
                Button("Add to Plan") {
                    // Handle add to plan
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(type.color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
