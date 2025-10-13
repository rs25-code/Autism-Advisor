//
//  GamePlanTabView.swift
//  Autism
//
//  Created by Rhea Sreedhar on 9/9/25.
//

import SwiftUI

// MARK: - Game Theory Data Models
struct ActiveCollaboration: Identifiable {  // Added Identifiable conformance
    let id = UUID()
    let goalArea: String
    let parentStrategy: String
    let teacherStrategy: String
    let counselorStrategy: String
    let coordinationLevel: CoordinationLevel
    let studentProgress: Int
    let daysActive: Int
    let nextMilestone: String
    let isWinCondition: Bool
}

struct ProgressToken {
    let id = UUID()
    let title: String
    let description: String
    let earnedDate: Date
    let tokenType: TokenType
    let collaborators: [UserRole]
    
    enum TokenType: String, CaseIterable {
        case coordination = "Coordination"
        case consistency = "Consistency"
        case engagement = "Full Team"
        case breakthrough = "Breakthrough"
        
        var icon: String {
            switch self {
            case .coordination: return "arrow.triangle.merge"
            case .consistency: return "checkmark.circle.fill"
            case .engagement: return "person.3.fill"
            case .breakthrough: return "star.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .coordination: return .blue
            case .consistency: return .green
            case .engagement: return .purple
            case .breakthrough: return .yellow
            }
        }
    }
}

struct MilestoneBadge {
    let id = UUID()
    let title: String
    let description: String
    let unlockedDate: Date?
    let requiredTokens: Int
    let currentTokens: Int
    let badgeLevel: BadgeLevel
    let isUnlocked: Bool
    
    enum BadgeLevel: String, CaseIterable {
        case bronze = "Bronze"
        case silver = "Silver"
        case gold = "Gold"
        case platinum = "Platinum"
        
        var color: Color {
            switch self {
            case .bronze: return .brown
            case .silver: return .gray
            case .gold: return .yellow
            case .platinum: return .purple
            }
        }
        
        var icon: String {
            switch self {
            case .bronze: return "medal.fill"
            case .silver: return "medal.fill"
            case .gold: return "medal.fill"
            case .platinum: return "crown.fill"
            }
        }
    }
}

enum CoordinationLevel: String, CaseIterable {
    case excellent = "Excellent Sync"
    case good = "Good Alignment"
    case developing = "Building Coordination"
    case needsWork = "Needs Alignment"
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .blue
        case .developing: return .orange
        case .needsWork: return .red
        }
    }
    
    var progress: Double {
        switch self {
        case .excellent: return 0.9
        case .good: return 0.7
        case .developing: return 0.5
        case .needsWork: return 0.3
        }
    }
}

struct StrategyRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let targetRole: UserRole
    let complementsAction: String
    let expectedOutcome: String
    let difficulty: RecommendationDifficulty
    let estimatedImpact: Double
    
    enum RecommendationDifficulty: String {
        case easy = "Easy Win"
        case moderate = "Moderate Effort"
        case challenging = "Strategic Challenge"
        
        var color: Color {
            switch self {
            case .easy: return .green
            case .moderate: return .orange
            case .challenging: return .red
            }
        }
    }
}

// MARK: - Main Game Plan Tab View
struct GamePlanTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var expandedCollaborations: Set<UUID> = []
    @State private var selectedCollaboration: ActiveCollaboration?
    @State private var showingTokenHistory = false
    @State private var showingBadgeCollection = false
    @State private var showingStrategyDetails = false
    @State private var engagementScore: Double = 0
    @State private var animatedTokenCount: Int = 0
    @State private var animatedBadgeCount: Int = 0
    
    // Sample Data
    private let activeCollaborations: [ActiveCollaboration] = [
        ActiveCollaboration(
            goalArea: "Reading Comprehension",
            parentStrategy: "15-min daily reading with discussion questions",
            teacherStrategy: "Small group guided reading with comprehension focus",
            counselorStrategy: "Social stories about reading success",
            coordinationLevel: .excellent,
            studentProgress: 78,
            daysActive: 12,
            nextMilestone: "Grade-level comprehension",
            isWinCondition: true
        ),
        ActiveCollaboration(
            goalArea: "Social Skills",
            parentStrategy: "Structured playdates with peer interaction goals",
            teacherStrategy: "Lunch bunch social skills group",
            counselorStrategy: "Weekly social coaching sessions",
            coordinationLevel: .good,
            studentProgress: 65,
            daysActive: 8,
            nextMilestone: "Independent peer initiation",
            isWinCondition: false
        ),
        ActiveCollaboration(
            goalArea: "Math Problem Solving",
            parentStrategy: "Visual math tools and manipulatives at home",
            teacherStrategy: "Multi-step problem breakdown strategies",
            counselorStrategy: "Confidence building for math anxiety",
            coordinationLevel: .developing,
            studentProgress: 42,
            daysActive: 5,
            nextMilestone: "Two-step problem mastery",
            isWinCondition: false
        )
    ]
    
    private let earnedTokens: [ProgressToken] = [
        ProgressToken(
            title: "Perfect Coordination",
            description: "All team members aligned on reading strategy",
            earnedDate: Date().addingTimeInterval(-86400 * 2),
            tokenType: .coordination,
            collaborators: [.parent, .teacher, .counselor]
        ),
        ProgressToken(
            title: "7-Day Consistency Streak",
            description: "Maintained daily practice for one week",
            earnedDate: Date().addingTimeInterval(-86400 * 1),
            tokenType: .consistency,
            collaborators: [.parent, .teacher]
        ),
        ProgressToken(
            title: "Full Team Activation",
            description: "All three roles actively supporting math goal",
            earnedDate: Date().addingTimeInterval(-3600 * 6),
            tokenType: .engagement,
            collaborators: [.parent, .teacher, .counselor]
        ),
        ProgressToken(
            title: "Reading Breakthrough",
            description: "Student achieved comprehension milestone",
            earnedDate: Date().addingTimeInterval(-3600 * 2),
            tokenType: .breakthrough,
            collaborators: [.parent, .teacher]
        )
    ]
    
    private let availableBadges: [MilestoneBadge] = [
        MilestoneBadge(
            title: "Team Builder",
            description: "Activated all three support roles",
            unlockedDate: Date().addingTimeInterval(-86400 * 3),
            requiredTokens: 3,
            currentTokens: 4,
            badgeLevel: .bronze,
            isUnlocked: true
        ),
        MilestoneBadge(
            title: "Consistency Champion",
            description: "Maintained strategy for 30 days",
            unlockedDate: nil,
            requiredTokens: 12,
            currentTokens: 4,
            badgeLevel: .silver,
            isUnlocked: false
        ),
        MilestoneBadge(
            title: "Goal Crusher",
            description: "Achieved 3 major milestones",
            unlockedDate: nil,
            requiredTokens: 25,
            currentTokens: 4,
            badgeLevel: .gold,
            isUnlocked: false
        )
    ]
    
    private let strategyRecommendations: [StrategyRecommendation] = [
        StrategyRecommendation(
            title: "Reading Comprehension Boost",
            description: "Teacher's guided questions + parent's discussion time could accelerate progress. Parent can reinforce by using similar question stems at home.",
            targetRole: .parent,
            complementsAction: "Small group guided reading",
            expectedOutcome: "15% boost in comprehension",
            difficulty: .easy,
            estimatedImpact: 0.8
        ),
        StrategyRecommendation(
            title: "Social Skills Breakthrough",
            description: "Parent's structured playdates + teacher's lunch group could unlock peer initiation milestone.",
            targetRole: .counselor,
            complementsAction: "Structured social activities",
            expectedOutcome: "Independent peer interactions",
            difficulty: .moderate,
            estimatedImpact: 0.9
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with Engagement Score
                headerSection
                
                // Active Collaborations
                activeCollaborationsSection
                
                // Progress Tokens & Badges
                tokensAndBadgesSection
                
                // Strategy Recommendations
                strategyRecommendationsSection
            }
            .padding()
        }
        .fullScreenCover(item: $selectedCollaboration) { collaboration in
            DetailedCollaborationView(collaboration: collaboration)
        }
        .fullScreenCover(isPresented: $showingTokenHistory) {
            TokenHistoryView(tokens: earnedTokens)
        }
        .fullScreenCover(isPresented: $showingBadgeCollection) {
            BadgeCollectionView(badges: availableBadges)
        }
        .onAppear {
            startEngagementAnimation()
            startCounterAnimations()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Game Plan")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Cooperative strategy for student success")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Engagement Score Ring
                ZStack {
                    Circle()
                        .stroke(Color.orange.opacity(0.2), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: engagementScore)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 2), value: engagementScore)
                    
                    VStack {
                        Text("\(Int(engagementScore * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                        Text("Sync")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Quick Stats
            HStack(spacing: 0) {
                QuickStatCard(
                    title: "Active Goals",
                    value: "\(activeCollaborations.count)",
                    icon: "target",
                    color: .blue
                )
                
                Divider()
                    .frame(height: 30)
                
                QuickStatCard(
                    title: "Win Conditions",
                    value: "\(activeCollaborations.filter { $0.isWinCondition }.count)",
                    icon: "trophy.fill",
                    color: .yellow
                )
                
                Divider()
                    .frame(height: 30)
                
                QuickStatCard(
                    title: "Team Score",
                    value: "85%",
                    icon: "person.3.fill",
                    color: .green
                )
            }
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var activeCollaborationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Collaborations")
                .font(.title3)
                .fontWeight(.semibold)
            
            ForEach(activeCollaborations) { collaboration in
                CollaborationCard(
                    collaboration: collaboration,
                    isExpanded: expandedCollaborations.contains(collaboration.id),
                    onToggle: {
                        withAnimation(.spring()) {
                            if expandedCollaborations.contains(collaboration.id) {
                                expandedCollaborations.remove(collaboration.id)
                            } else {
                                expandedCollaborations.insert(collaboration.id)
                            }
                        }
                    },
                    onTap: {
                        selectedCollaboration = collaboration
                    }
                )
            }
        }
    }
    
    private var tokensAndBadgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress & Achievements")
                .font(.title3)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                // Tokens Card
                Button(action: { showingTokenHistory = true }) {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading) {
                                Text("Progress Tokens")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text("Earned this week")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(animatedTokenCount)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        
                        // Recent tokens preview
                        HStack(spacing: 4) {
                            ForEach(earnedTokens.prefix(3), id: \.id) { token in
                                Circle()
                                    .fill(token.tokenType.color)
                                    .frame(width: 8, height: 8)
                            }
                            if earnedTokens.count > 3 {
                                Text("+\(earnedTokens.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Badges Card
                Button(action: { showingBadgeCollection = true }) {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "medal.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                            
                            VStack(alignment: .leading) {
                                Text("Milestone Badges")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text("Unlocked")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(animatedBadgeCount)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                        
                        // Badge progress indicators
                        HStack(spacing: 4) {
                            ForEach(availableBadges.prefix(3), id: \.id) { badge in
                                Circle()
                                    .fill(badge.isUnlocked ? badge.badgeLevel.color : Color(.systemGray4))
                                    .frame(width: 8, height: 8)
                            }
                            if availableBadges.count > 3 {
                                Text("+\(availableBadges.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var strategyRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Strategic Recommendations")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("See All") {
                    showingStrategyDetails = true
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }
            
            ForEach(strategyRecommendations) { recommendation in
                StrategyCard(recommendation: recommendation)
            }
        }
    }
    
    private func startEngagementAnimation() {
        withAnimation(.easeInOut(duration: 2).delay(0.5)) {
            engagementScore = 0.85
        }
    }
    
    private func startCounterAnimations() {
        // Animate token count
        let targetTokens = earnedTokens.count
        for i in 0...targetTokens {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                animatedTokenCount = i
            }
        }
        
        // Animate badge count
        let targetBadges = availableBadges.filter { $0.isUnlocked }.count
        for i in 0...targetBadges {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15 + 0.5) {
                animatedBadgeCount = i
            }
        }
    }
}

// MARK: - Supporting Views
struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }
}

struct CollaborationCard: View {
    let collaboration: ActiveCollaboration
    let isExpanded: Bool
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Collaboration Header
            Button(action: onToggle) {
                HStack(spacing: 16) {
                    // Win indicator or progress ring
                    ZStack {
                        Circle()
                            .stroke(collaboration.coordinationLevel.color.opacity(0.2), lineWidth: 6)
                            .frame(width: 50, height: 50)
                        
                        if collaboration.isWinCondition {
                            Image(systemName: "trophy.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                        } else {
                            Circle()
                                .trim(from: 0, to: collaboration.coordinationLevel.progress)
                                .stroke(collaboration.coordinationLevel.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.5), value: collaboration.coordinationLevel.progress)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(collaboration.goalArea)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            if collaboration.isWinCondition {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Text(collaboration.coordinationLevel.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(collaboration.coordinationLevel.color.opacity(0.1))
                            .foregroundColor(collaboration.coordinationLevel.color)
                            .cornerRadius(6)
                        
                        Text("Day \(collaboration.daysActive) • \(collaboration.studentProgress)% progress")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded Content
            if isExpanded {
                VStack(spacing: 16) {
                    Divider()
                    
                    // Strategy Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Strategies")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            StrategyRow(role: .parent, strategy: collaboration.parentStrategy)
                            StrategyRow(role: .teacher, strategy: collaboration.teacherStrategy)
                            StrategyRow(role: .counselor, strategy: collaboration.counselorStrategy)
                        }
                    }
                    
                    // Next Milestone
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Next Milestone")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text(collaboration.nextMilestone)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        Button("View Details") {
                            onTap()
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(collaboration.coordinationLevel.color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct StrategyRow: View {
    let role: UserRole
    let strategy: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: role.icon)
                .font(.caption)
                .foregroundColor(role.color)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(role.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(role.color)
                
                Text(strategy)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct StrategyCard: View {
    let recommendation: StrategyRecommendation
    @State private var isVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 8) {
                        Image(systemName: recommendation.targetRole.icon)
                            .font(.caption)
                            .foregroundColor(recommendation.targetRole.color)
                        
                        Text("Target: \(recommendation.targetRole.displayName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(recommendation.difficulty.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(recommendation.difficulty.color.opacity(0.1))
                            .foregroundColor(recommendation.difficulty.color)
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                // Impact indicator
                VStack(spacing: 4) {
                    Text("Impact")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Circle()
                                .fill(Double(index) < recommendation.estimatedImpact * 5 ?
                                      Color.orange : Color(.systemGray4))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            
            Text(recommendation.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Text("Complements: \(recommendation.complementsAction)")
                    .font(.caption2)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Button("Try This Strategy") {
                    // Handle strategy selection
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .foregroundColor(.orange)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(recommendation.targetRole.color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: isVisible)
        .onAppear {
            isVisible = true
        }
    }
}

// MARK: - Detailed Views
struct DetailedCollaborationView: View {
    let collaboration: ActiveCollaboration
    @Environment(\.dismiss) private var dismiss
    @State private var progressAnimation: Double = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Done") {
                    dismiss()
                }
                .padding()
                Spacer()
                Text("Team Collaboration")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("") { }
                    .opacity(0)
                    .padding()
            }
            .background(Color(.systemGray6))
            
            ScrollView {
                VStack(spacing: 24) {
                    // Collaboration Header with Win Status
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(collaboration.isWinCondition ?
                                      Color.yellow.opacity(0.1) : collaboration.coordinationLevel.color.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            if collaboration.isWinCondition {
                                VStack {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.yellow)
                                    Text("WIN!")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.yellow)
                                }
                            } else {
                                VStack {
                                    Text("\(collaboration.studentProgress)%")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(collaboration.coordinationLevel.color)
                                    Text("Progress")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        VStack(spacing: 8) {
                            Text(collaboration.goalArea)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(collaboration.coordinationLevel.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(collaboration.coordinationLevel.color.opacity(0.1))
                                .foregroundColor(collaboration.coordinationLevel.color)
                                .cornerRadius(8)
                            
                            Text("Active for \(collaboration.daysActive) days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Progress Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Progress Overview")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Current Progress")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(collaboration.studentProgress)%")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(collaboration.coordinationLevel.color)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                        .frame(height: 12)
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(collaboration.coordinationLevel.color)
                                        .frame(width: geometry.size.width * progressAnimation, height: 12)
                                        .animation(.easeInOut(duration: 1.5), value: progressAnimation)
                                }
                            }
                            .frame(height: 12)
                            .onAppear {
                                progressAnimation = Double(collaboration.studentProgress) / 100.0
                            }
                            
                            HStack {
                                Text("Next Milestone")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(collaboration.nextMilestone)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        )
                    }
                    
                    // Team Strategy Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Team Strategy")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            DetailedStrategyRow(role: .parent, strategy: collaboration.parentStrategy)
                            DetailedStrategyRow(role: .teacher, strategy: collaboration.teacherStrategy)
                            DetailedStrategyRow(role: .counselor, strategy: collaboration.counselorStrategy)
                        }
                    }
                    
                    // Coordination Level Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Team Coordination")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "arrow.triangle.merge")
                                    .font(.title2)
                                    .foregroundColor(collaboration.coordinationLevel.color)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(collaboration.coordinationLevel.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text(coordinationDescription(for: collaboration.coordinationLevel))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Circle()
                                    .fill(collaboration.coordinationLevel.color)
                                    .frame(width: 12, height: 12)
                            }
                            .padding()
                            .background(collaboration.coordinationLevel.color.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private func coordinationDescription(for level: CoordinationLevel) -> String {
        switch level {
        case .excellent:
            return "All team members are perfectly aligned and working in sync"
        case .good:
            return "Team members are well coordinated with minor adjustments needed"
        case .developing:
            return "Team is building coordination, some alignment still needed"
        case .needsWork:
            return "Team coordination needs improvement for better outcomes"
        }
    }
}

struct DetailedStrategyRow: View {
    let role: UserRole
    let strategy: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: role.icon)
                    .font(.title3)
                    .foregroundColor(role.color)
                    .frame(width: 24)
                
                Text(role.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(role.color)
                
                Spacer()
            }
            
            Text(strategy)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(role.color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Token History View
struct TokenHistoryView: View {
    let tokens: [ProgressToken]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(tokens, id: \.id) { token in
                        TokenHistoryCard(token: token)
                    }
                }
                .padding()
            }
            .navigationTitle("Progress Tokens")
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

struct TokenHistoryCard: View {
    let token: ProgressToken
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: token.tokenType.icon)
                    .font(.title2)
                    .foregroundColor(token.tokenType.color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(token.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(token.tokenType.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(token.tokenType.color.opacity(0.1))
                        .foregroundColor(token.tokenType.color)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(token.earnedDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(token.earnedDate, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(token.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Team:")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                ForEach(token.collaborators, id: \.self) { role in
                    HStack(spacing: 4) {
                        Image(systemName: role.icon)
                            .font(.caption2)
                            .foregroundColor(role.color)
                        Text(role.displayName)
                            .font(.caption2)
                            .foregroundColor(role.color)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(token.tokenType.color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Badge Collection View
struct BadgeCollectionView: View {
    let badges: [MilestoneBadge]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(badges, id: \.id) { badge in
                        BadgeCard(badge: badge)
                    }
                }
                .padding()
            }
            .navigationTitle("Milestone Badges")
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

struct BadgeCard: View {
    let badge: MilestoneBadge
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge Icon with Glow Effect
            ZStack {
                // Outer glow for unlocked badges
                if badge.isUnlocked {
                    Circle()
                        .fill(badge.badgeLevel.color.opacity(0.3))
                        .frame(width: 90, height: 90)
                        .blur(radius: 8)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                }
                
                Circle()
                    .fill(badge.isUnlocked ? badge.badgeLevel.color.opacity(0.1) : Color(.systemGray6))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(badge.isUnlocked ? badge.badgeLevel.color.opacity(0.3) : Color(.systemGray5), lineWidth: 2)
                    )
                
                Image(systemName: badge.badgeLevel.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(badge.isUnlocked ? badge.badgeLevel.color : Color(.systemGray4))
                    .scaleEffect(badge.isUnlocked && isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                // Lock overlay for locked badges
                if !badge.isUnlocked {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            
            // Badge Title and Level
            VStack(spacing: 4) {
                Text(badge.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(badge.isUnlocked ? .primary : .secondary)
                    .lineLimit(2)
                
                Text(badge.badgeLevel.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(badge.isUnlocked ? badge.badgeLevel.color.opacity(0.1) : Color(.systemGray6))
                    .foregroundColor(badge.isUnlocked ? badge.badgeLevel.color : .secondary)
                    .cornerRadius(6)
            }
            
            // Badge Description
            Text(badge.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(3)
            
            // Progress Section or Unlock Date
            if !badge.isUnlocked {
                VStack(spacing: 6) {
                    HStack {
                        Text("Progress")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(badge.currentTokens)/\(badge.requiredTokens)")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(.systemGray6))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.orange)
                                .frame(width: max(4, geometry.size.width * (Double(badge.currentTokens) / Double(badge.requiredTokens))), height: 4)
                                .animation(.easeInOut(duration: 1), value: badge.currentTokens)
                        }
                    }
                    .frame(height: 4)
                    
                    let tokensNeeded = badge.requiredTokens - badge.currentTokens
                    if tokensNeeded > 0 {
                        Text("\(tokensNeeded) more token\(tokensNeeded == 1 ? "" : "s") needed")
                            .font(.caption2)
                            .foregroundColor(.orange)
                            .italic()
                    }
                }
            } else if let unlockedDate = badge.unlockedDate {
                VStack(spacing: 2) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("Unlocked!")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                    
                    Text(unlockedDate, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    badge.isUnlocked ?
                    badge.badgeLevel.color.opacity(0.3) :
                    Color(.systemGray5),
                    lineWidth: badge.isUnlocked ? 2 : 1
                )
        )
        .shadow(
            color: badge.isUnlocked ? badge.badgeLevel.color.opacity(0.2) : .clear,
            radius: badge.isUnlocked ? 8 : 0,
            x: 0,
            y: badge.isUnlocked ? 4 : 0
        )
        .scaleEffect(badge.isUnlocked ? 1.0 : 0.95)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: badge.isUnlocked)
        .onAppear {
            if badge.isUnlocked {
                withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                    isAnimating = true
                }
            }
        }
        .onTapGesture {
            // Add haptic feedback for unlocked badges
            if badge.isUnlocked {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }
    }
}
