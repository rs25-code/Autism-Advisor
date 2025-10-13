//
//  HomeStrategiesScreen.swift
//  Autism
//
//  Created by Rhea Sreedhar on 9/12/25.
//

import SwiftUI

struct HomeStrategiesScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStrategy: StrategyCategory? = nil
    @State private var selectedAge = AgeGroup.elementary
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    ageSelectionSection
                    strategyCategoriesSection
                    quickTipsSection
                    resourcesSection
                }
                .padding()
            }
            .navigationTitle("Home Strategies")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .sheet(item: $selectedStrategy) { strategy in
            StrategyDetailView(category: strategy, ageGroup: selectedAge)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "house.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                Text("Supporting Learning at Home")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Evidence-based strategies to help your child with autism thrive at home")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
    
    // MARK: - Age Selection
    private var ageSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Age Group")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ForEach(AgeGroup.allCases, id: \.self) { age in
                    Button(action: { selectedAge = age }) {
                        Text(age.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedAge == age ? Color.orange : Color(.systemGray6))
                            )
                            .foregroundColor(selectedAge == age ? .white : .primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Strategy Categories
    private var strategyCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Strategy Categories")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(StrategyCategory.allCases, id: \.self) { category in
                    StrategyCategoryCard(category: category) {
                        selectedStrategy = category
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Tips
    private var quickTipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Quick Tips")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(getQuickTips(for: selectedAge), id: \.title) { tip in
                    QuickTipCard(tip: tip)
                }
            }
        }
    }
    
    // MARK: - Resources
    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Additional Resources")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ResourceCard(
                    title: "Autism Helper",
                    description: "Visual supports and social stories",
                    url: "https://www.autismhelper.com/",
                    icon: "photo.fill",
                    color: .blue
                )
                
                ResourceCard(
                    title: "Social Thinking",
                    description: "Social learning curricula and strategies",
                    url: "https://www.socialthinking.com/",
                    icon: "person.2.fill",
                    color: .green
                )
                
                ResourceCard(
                    title: "National Autism Center",
                    description: "Evidence-based practice guides",
                    url: "https://www.nationalautismcenter.org/",
                    icon: "book.closed.fill",
                    color: .purple
                )
                
                ResourceCard(
                    title: "Autism Speaks Toolkits",
                    description: "Daily living and social skills resources",
                    url: "https://www.autismspeaks.org/tool-kits",
                    icon: "wrench.and.screwdriver.fill",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getQuickTips(for ageGroup: AgeGroup) -> [QuickTip] {
        switch ageGroup {
        case .preschool:
            return [
                QuickTip(title: "Visual Schedules", description: "Use pictures to show daily routines", icon: "calendar"),
                QuickTip(title: "Sensory Breaks", description: "Schedule quiet time for sensory regulation", icon: "pause.circle"),
                QuickTip(title: "Simple Choices", description: "Offer 2 options to build decision-making", icon: "hand.point.up"),
                QuickTip(title: "Consistent Routines", description: "Keep mealtimes and bedtimes predictable", icon: "clock")
            ]
        case .elementary:
            return [
                QuickTip(title: "Homework Station", description: "Create a dedicated, distraction-free workspace", icon: "desk"),
                QuickTip(title: "Timer Use", description: "Break tasks into timed segments", icon: "timer"),
                QuickTip(title: "Social Scripts", description: "Practice conversation starters and responses", icon: "text.bubble"),
                QuickTip(title: "Reward Systems", description: "Use token boards for motivation", icon: "star.circle")
            ]
        case .middle:
            return [
                QuickTip(title: "Organization Tools", description: "Use planners and color-coding systems", icon: "folder"),
                QuickTip(title: "Self-Advocacy", description: "Practice asking for help and accommodations", icon: "hand.raised"),
                QuickTip(title: "Emotional Check-ins", description: "Regular mood discussions and coping strategies", icon: "heart"),
                QuickTip(title: "Independence Building", description: "Gradually increase self-care responsibilities", icon: "figure.walk")
            ]
        case .high:
            return [
                QuickTip(title: "Transition Planning", description: "Discuss post-graduation goals regularly", icon: "arrow.right.circle"),
                QuickTip(title: "Life Skills Practice", description: "Work on cooking, budgeting, and time management", icon: "house"),
                QuickTip(title: "Social Opportunities", description: "Encourage participation in clubs or activities", icon: "person.3"),
                QuickTip(title: "Self-Determination", description: "Support decision-making and problem-solving", icon: "brain")
            ]
        }
    }
}

// MARK: - Supporting Models
enum AgeGroup: String, CaseIterable {
    case preschool = "preschool"
    case elementary = "elementary"
    case middle = "middle"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .preschool: return "3-5 years"
        case .elementary: return "6-11 years"
        case .middle: return "12-14 years"
        case .high: return "15-18 years"
        }
    }
}

enum StrategyCategory: String, CaseIterable, Identifiable {
    case communication = "Communication"
    case behavior = "Behavior Support"
    case sensory = "Sensory Strategies"
    case social = "Social Skills"
    case academic = "Academic Support"
    case daily = "Daily Living"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .communication: return "message.fill"
        case .behavior: return "checkmark.shield.fill"
        case .sensory: return "waveform.path"
        case .social: return "person.2.fill"
        case .academic: return "graduationcap.fill"
        case .daily: return "house.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .communication: return .blue
        case .behavior: return .green
        case .sensory: return .purple
        case .social: return .orange
        case .academic: return .red
        case .daily: return .cyan
        }
    }
    
    var description: String {
        switch self {
        case .communication: return "Enhance verbal and non-verbal communication"
        case .behavior: return "Positive behavior support strategies"
        case .sensory: return "Managing sensory sensitivities"
        case .social: return "Building social interaction skills"
        case .academic: return "Supporting learning at home"
        case .daily: return "Life skills and independence"
        }
    }
}

struct QuickTip {
    let title: String
    let description: String
    let icon: String
}

// MARK: - Supporting Views
struct StrategyCategoryCard: View {
    let category: StrategyCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(category.color)
                
                VStack(spacing: 4) {
                    Text(category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text(category.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.3))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickTipCard: View {
    let tip: QuickTip
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tip.icon)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(tip.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// ResourceCard struct is defined in UnderstandingIEPsScreen.swift

// MARK: - Strategy Detail View
struct StrategyDetailView: View {
    let category: StrategyCategory
    let ageGroup: AgeGroup
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    detailContent
                }
                .padding()
            }
            .navigationTitle(category.rawValue)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
    
    @ViewBuilder
    private var detailContent: some View {
        switch category {
        case .communication:
            communicationStrategies
        case .behavior:
            behaviorStrategies
        case .sensory:
            sensoryStrategies
        case .social:
            socialStrategies
        case .academic:
            academicStrategies
        case .daily:
            dailyLivingStrategies
        }
    }
    
    private var communicationStrategies: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Communication Strategies")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Supporting your child's communication development at home:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                StrategyPoint(title: "Visual Supports", description: "Use picture cards, visual schedules, and social stories to support understanding and expression.")
                
                StrategyPoint(title: "Wait Time", description: "Give your child extra time to process and respond to questions or instructions.")
                
                StrategyPoint(title: "Model Language", description: "Demonstrate appropriate communication by narrating activities and using clear, simple language.")
                
                StrategyPoint(title: "Communication Temptations", description: "Create opportunities for your child to request by placing preferred items out of reach.")
                
                StrategyPoint(title: "AAC Support", description: "If your child uses alternative communication, ensure devices are accessible and charged.")
            }
            
            Text("Age-Specific Tips for \(ageGroup.displayName):")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.top)
            
            Text(getCommunicationTips(for: ageGroup))
                .font(.body)
        }
    }
    
    private var behaviorStrategies: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Positive Behavior Support")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Evidence-based approaches to support positive behaviors:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                StrategyPoint(title: "Antecedent Strategies", description: "Prevent challenging behaviors by modifying the environment and providing clear expectations.")
                
                StrategyPoint(title: "Replacement Behaviors", description: "Teach appropriate ways to communicate needs that the challenging behavior was serving.")
                
                StrategyPoint(title: "Reinforcement", description: "Use preferred activities, items, or praise to strengthen positive behaviors.")
                
                StrategyPoint(title: "Consistency", description: "Maintain consistent responses to behaviors across all family members and settings.")
                
                StrategyPoint(title: "Data Collection", description: "Track when and where behaviors occur to identify patterns and triggers.")
            }
        }
    }
    
    private var sensoryStrategies: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sensory Regulation Support")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Help your child manage sensory needs:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                StrategyPoint(title: "Sensory Diet", description: "Incorporate regular sensory activities throughout the day (jumping, swinging, fidgets).")
                
                StrategyPoint(title: "Environmental Modifications", description: "Adjust lighting, sound levels, and textures to reduce overwhelming stimuli.")
                
                StrategyPoint(title: "Calming Space", description: "Create a quiet area where your child can retreat when feeling overwhelmed.")
                
                StrategyPoint(title: "Preparation", description: "Use visual or verbal warnings before sensory-rich activities (vacuuming, concerts).")
                
                StrategyPoint(title: "Self-Regulation Tools", description: "Teach your child to identify their sensory needs and use coping strategies.")
            }
        }
    }
    
    private var socialStrategies: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Social Skills Development")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Building social connections and understanding:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                StrategyPoint(title: "Social Stories", description: "Use stories to teach social expectations and appropriate responses in various situations.")
                
                StrategyPoint(title: "Role Playing", description: "Practice social interactions through structured play and modeling.")
                
                StrategyPoint(title: "Peer Opportunities", description: "Arrange structured playdates and group activities with clear expectations.")
                
                StrategyPoint(title: "Perspective Taking", description: "Help your child understand others' thoughts and feelings through discussion and examples.")
                
                StrategyPoint(title: "Social Problem Solving", description: "Teach strategies for handling social conflicts and misunderstandings.")
            }
        }
    }
    
    private var academicStrategies: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Academic Support at Home")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Reinforce school learning in the home environment:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                StrategyPoint(title: "Structured Homework Time", description: "Establish consistent routines and distraction-free workspace for academic tasks.")
                
                StrategyPoint(title: "Break Down Tasks", description: "Divide large assignments into smaller, manageable steps with clear completion criteria.")
                
                StrategyPoint(title: "Visual Learning Aids", description: "Use charts, diagrams, and graphic organizers to support understanding.")
                
                StrategyPoint(title: "Special Interests", description: "Incorporate your child's interests into learning activities to increase motivation.")
                
                StrategyPoint(title: "School Collaboration", description: "Maintain regular communication with teachers about strategies that work at home.")
            }
        }
    }
    
    private var dailyLivingStrategies: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Living Skills")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Building independence in everyday activities:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                StrategyPoint(title: "Task Analysis", description: "Break daily activities into step-by-step instructions with visual supports.")
                
                StrategyPoint(title: "Gradual Release", description: "Start with full assistance, then gradually reduce support as skills develop.")
                
                StrategyPoint(title: "Practice Opportunities", description: "Create regular chances to practice life skills in natural contexts.")
                
                StrategyPoint(title: "Positive Reinforcement", description: "Celebrate attempts and progress, not just perfect completion.")
                
                StrategyPoint(title: "Functional Skills Focus", description: "Prioritize skills that will increase independence and quality of life.")
            }
        }
    }
    
    private func getCommunicationTips(for ageGroup: AgeGroup) -> String {
        switch ageGroup {
        case .preschool:
            return "Focus on basic requesting, following simple instructions, and using gestures or pictures to communicate needs."
        case .elementary:
            return "Work on conversational turn-taking, asking questions, and using more complex language to describe experiences."
        case .middle:
            return "Practice abstract language, sarcasm understanding, and appropriate communication across different social contexts."
        case .high:
            return "Focus on job interview skills, advocacy, and maintaining relationships through various communication methods."
        }
    }
}

struct StrategyPoint: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
            
            Text(description)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.3))
        )
    }
}

// MARK: - Preview
struct HomeStrategiesScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeStrategiesScreen()
    }
}
