//
//  ServicesTabView.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI

struct ServicesTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var expandedCategories: Set<UUID> = []
    @State private var selectedService: CurrentService?
    @State private var selectedNeed: AdditionalNeed?
    @State private var showingServiceSummary = false
    
    private let serviceCategories: [ServiceCategory] = [
        ServiceCategory(
            title: "Current Educational Services",
            icon: "graduationcap.fill",
            color: .blue,
            currentServices: [
                CurrentService(
                    name: "Specialized Academic Instruction",
                    frequency: "Daily",
                    duration: "306 minutes daily",
                    location: "Separate public integrated classroom",
                    weeklyMinutes: 1530,
                    yearlyMinutes: nil,
                    provider: "Special Education Teacher",
                    status: .current
                ),
                CurrentService(
                    name: "Intensive Individual Services",
                    frequency: "Daily",
                    duration: "1835 minutes weekly",
                    location: "Separate public integrated classroom",
                    weeklyMinutes: 1835,
                    yearlyMinutes: nil,
                    provider: "Support Staff",
                    status: .current
                ),
                CurrentService(
                    name: "General Education Integration",
                    frequency: "Modified Wednesdays",
                    duration: "Lunch and recess",
                    location: "General education classroom",
                    weeklyMinutes: 60,
                    yearlyMinutes: nil,
                    provider: "General Education Teacher",
                    status: .current
                )
            ],
            additionalNeeds: [
                AdditionalNeed(
                    area: "Academic Support Strategies",
                    description: "Requires accommodations and modifications to curriculum and environment",
                    strategies: [
                        "Direct instruction",
                        "Short directions",
                        "Gradual increase in task length",
                        "Explicit demonstrations",
                        "Hands-on activities",
                        "Alternative curriculum for ELA and Math",
                        "Small group instruction"
                    ],
                    priority: .high,
                    status: .needed
                ),
                AdditionalNeed(
                    area: "Specific Academic Focus Areas",
                    description: "Targeted support needed for reading, math, and writing skills",
                    strategies: [
                        "Reading comprehension (drawing conclusions, sequencing)",
                        "Mathematics (working quickly, recalling facts, multi-step problems)",
                        "Writing skills (grammar, verb tense, conceptual writing)",
                        "Technology support (typing on Chromebook)"
                    ],
                    priority: .high,
                    status: .needed
                )
            ],
            overallStatus: .adequate
        ),
        ServiceCategory(
            title: "Communication & Language Services",
            icon: "message.fill",
            color: .green,
            currentServices: [
                CurrentService(
                    name: "Speech and Language Services",
                    frequency: "Daily",
                    duration: "20 minutes daily",
                    location: "Separate public integrated classroom",
                    weeklyMinutes: 100,
                    yearlyMinutes: 1000,
                    provider: "Speech-Language Pathologist",
                    status: .current
                )
            ],
            additionalNeeds: [
                AdditionalNeed(
                    area: "Expressive & Receptive Language",
                    description: "Significant deficits affecting understanding of WH questions, common world knowledge, and complex sentences",
                    strategies: [
                        "Verbal and nonverbal communication support",
                        "Address atypical language patterns",
                        "Enhance understanding of body language and gestures",
                        "Improve responses to expressions of affection/appreciation"
                    ],
                    priority: .high,
                    status: .needed
                ),
                AdditionalNeed(
                    area: "Pragmatic Language",
                    description: "Support needed for appropriate social communication and interaction",
                    strategies: [
                        "Social communication training",
                        "Appropriate response patterns",
                        "Turn-taking in conversation",
                        "Understanding social cues"
                    ],
                    priority: .high,
                    status: .needed
                )
            ],
            overallStatus: .insufficient
        ),
        ServiceCategory(
            title: "Occupational Therapy Services",
            icon: "hand.point.up.fill",
            color: .orange,
            currentServices: [
                CurrentService(
                    name: "Occupational Therapy",
                    frequency: "Daily",
                    duration: "20 minutes daily",
                    location: "Separate public integrated classroom",
                    weeklyMinutes: 100,
                    yearlyMinutes: 100,
                    provider: "Occupational Therapist",
                    status: .current
                ),
                CurrentService(
                    name: "Sensory Consultation",
                    frequency: "As needed",
                    duration: "Consultation",
                    location: "Separate public integrated classroom",
                    weeklyMinutes: 30,
                    yearlyMinutes: nil,
                    provider: "Occupational Therapist",
                    status: .current
                )
            ],
            additionalNeeds: [
                AdditionalNeed(
                    area: "Fine Motor & Visual-Motor Skills",
                    description: "Support needed for functional fine motor development",
                    strategies: [
                        "Grasp-pincer development",
                        "In-hand manipulation/dexterity",
                        "Crossing midline exercises",
                        "Bilateral coordination",
                        "Various cutting skills",
                        "Visual-motor abilities (drawing improvement)"
                    ],
                    priority: .high,
                    status: .needed
                ),
                AdditionalNeed(
                    area: "Sensory Processing Support",
                    description: "Addressing heightened sensitivities and sensory seeking/avoiding patterns",
                    strategies: [
                        "Sensory accommodations for sound sensitivity",
                        "Support for 'Seeking/Seeker' patterns",
                        "Management of 'Avoiding/Avoider' behaviors",
                        "Address 'Sensitivity/Sensor' responses",
                        "Support for 'Registration/Bystander' patterns",
                        "Toilet flushing desensitization"
                    ],
                    priority: .high,
                    status: .needed
                )
            ],
            overallStatus: .insufficient
        ),
        ServiceCategory(
            title: "Social-Emotional & Behavioral Support",
            icon: "heart.fill",
            color: .pink,
            currentServices: [],
            additionalNeeds: [
                AdditionalNeed(
                    area: "Social Skills Training",
                    description: "Enhancement of peer and adult socialization skills",
                    strategies: [
                        "Peer interaction training",
                        "Adult socialization support",
                        "Social awareness development",
                        "Reciprocal social/emotional interactions",
                        "Social cognition improvement"
                    ],
                    priority: .high,
                    status: .needed
                ),
                AdditionalNeed(
                    area: "Behavioral Regulation Support",
                    description: "Addressing repetitive behaviors, resistance to change, and emotional regulation",
                    strategies: [
                        "Positive behavioral supports for stereotyped behaviors",
                        "Managing behavioral rigidity",
                        "Self-regulation strategies",
                        "Managing inattention and hyperactivity",
                        "Addressing defiance/aggression",
                        "Routine change adaptation"
                    ],
                    priority: .high,
                    status: .needed
                ),
                AdditionalNeed(
                    area: "Sensory-Related Behavioral Support",
                    description: "Managing behaviors related to sensory experiences",
                    strategies: [
                        "Group participation support",
                        "Eye contact improvement",
                        "Appropriate touching boundaries",
                        "Fidgeting management",
                        "De-escalation for screaming/crying",
                        "Safe handling of throwing/hitting behaviors"
                    ],
                    priority: .high,
                    status: .needed
                )
            ],
            overallStatus: .needed
        ),
        ServiceCategory(
            title: "Daily Living & Vocational Support",
            icon: "house.fill",
            color: .purple,
            currentServices: [],
            additionalNeeds: [
                AdditionalNeed(
                    area: "Daily Living Skills",
                    description: "Ongoing support for reinforcement of learned routines and rules",
                    strategies: [
                        "Routine and rule reinforcement",
                        "Organizational skills improvement",
                        "Independence building",
                        "Self-care skills development"
                    ],
                    priority: .medium,
                    status: .needed
                ),
                AdditionalNeed(
                    area: "Vocational & Life Skills",
                    description: "Practice with money management and time concepts",
                    strategies: [
                        "Money management (adding/mixing coins and bills)",
                        "Dollar-up method practice",
                        "Time telling (analog and digital)",
                        "Functional life skills development"
                    ],
                    priority: .medium,
                    status: .needed
                )
            ],
            overallStatus: .needed
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with Service Summary
                headerSection
                
                // Service Category Cards
                VStack(spacing: 16) {
                    ForEach(serviceCategories, id: \.id) { category in
                        ServiceCategoryCard(
                            category: category,
                            isExpanded: expandedCategories.contains(category.id)
                        ) {
                            toggleCategory(category.id)
                        } onServiceTap: { service in
                            selectedService = service
                        } onNeedTap: { need in
                            selectedNeed = need
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(item: $selectedService) { service in
            DetailedServiceView(service: service)
        }
        .sheet(item: $selectedNeed) { need in
            DetailedNeedView(need: need)
        }
        .sheet(isPresented: $showingServiceSummary) {
            ServiceSummaryView(categories: serviceCategories)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Special Education Services")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Current services and additional support needs")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: { showingServiceSummary = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text.magnifyingglass")
                        Text("Summary")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
            }
            
            // Service Overview Stats
            HStack(spacing: 20) {
                ServiceStatCard(
                    title: "Current Services",
                    value: "\(serviceCategories.flatMap { $0.currentServices }.count)",
                    color: .green,
                    icon: "checkmark.circle.fill"
                )
                
                ServiceStatCard(
                    title: "Additional Needs",
                    value: "\(serviceCategories.flatMap { $0.additionalNeeds }.count)",
                    color: .orange,
                    icon: "plus.circle.fill"
                )
                
                ServiceStatCard(
                    title: "Weekly Minutes",
                    value: "\(serviceCategories.flatMap { $0.currentServices }.reduce(0) { $0 + $1.weeklyMinutes })",
                    color: .blue,
                    icon: "clock.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
    
    private func toggleCategory(_ categoryId: UUID) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if expandedCategories.contains(categoryId) {
                expandedCategories.remove(categoryId)
            } else {
                expandedCategories.insert(categoryId)
            }
        }
    }
}

// MARK: - Service Category Card
struct ServiceCategoryCard: View {
    let category: ServiceCategory
    let isExpanded: Bool
    let onToggle: () -> Void
    let onServiceTap: (CurrentService) -> Void
    let onNeedTap: (AdditionalNeed) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Header
            Button(action: onToggle) {
                HStack(spacing: 16) {
                    // Icon and Status Indicator
                    ZStack {
                        Circle()
                            .stroke(category.color.opacity(0.2), lineWidth: 6)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .fill(category.overallStatus.color.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: category.icon)
                            .font(.title2)
                            .foregroundColor(category.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("\(category.currentServices.count) current")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(.green)
                                .cornerRadius(6)
                            
                            Text("\(category.additionalNeeds.count) needed")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(6)
                        }
                        
                        Text(category.overallStatus.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(category.overallStatus.color.opacity(0.1))
                            .foregroundColor(category.overallStatus.color)
                            .cornerRadius(6)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.title3)
                        .foregroundColor(category.color)
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
                .padding()
            }
            
            // Expandable Content
            if isExpanded {
                VStack(spacing: 16) {
                    Divider()
                        .background(category.color.opacity(0.3))
                    
                    // Current Services Section
                    if !category.currentServices.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Current Services")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            
                            ForEach(category.currentServices, id: \.id) { service in
                                CurrentServiceCard(service: service) {
                                    onServiceTap(service)
                                }
                            }
                        }
                    }
                    
                    // Additional Needs Section
                    if !category.additionalNeeds.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.orange)
                                Text("Additional Support Needed")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                            }
                            
                            ForEach(category.additionalNeeds, id: \.id) { need in
                                AdditionalNeedCard(need: need) {
                                    onNeedTap(need)
                                }
                            }
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
                .shadow(color: category.color.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(category.color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Supporting Service Cards
struct CurrentServiceCard: View {
    let service: CurrentService
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(service.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(service.provider)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(service.frequency)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                        
                        Text("\(service.weeklyMinutes) min/week")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("📍 \(service.location)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("⏱️ \(service.duration)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color.green.opacity(0.05))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct AdditionalNeedCard: View {
    let need: AdditionalNeed
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(need.area)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(need.priority.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(need.priority.color.opacity(0.1))
                            .foregroundColor(need.priority.color)
                            .cornerRadius(6)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(need.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Color.orange.opacity(0.05))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct ServiceStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
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

// MARK: - Detailed Views (Identifiable Extensions)
extension CurrentService: Identifiable {}
extension AdditionalNeed: Identifiable {}

struct DetailedServiceView: View {
    let service: CurrentService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Service Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(service.status.color.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: service.status.icon)
                                .font(.system(size: 40))
                                .foregroundColor(service.status.color)
                        }
                        
                        VStack(spacing: 8) {
                            Text(service.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text(service.provider)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Service Details
                    VStack(spacing: 16) {
                        ServiceDetailRow(
                            icon: "calendar",
                            title: "Frequency",
                            value: service.frequency,
                            color: .blue
                        )
                        
                        ServiceDetailRow(
                            icon: "clock",
                            title: "Duration",
                            value: service.duration,
                            color: .green
                        )
                        
                        ServiceDetailRow(
                            icon: "location",
                            title: "Location",
                            value: service.location,
                            color: .orange
                        )
                        
                        ServiceDetailRow(
                            icon: "chart.bar",
                            title: "Weekly Minutes",
                            value: "\(service.weeklyMinutes) minutes",
                            color: .purple
                        )
                        
                        if let yearlyMinutes = service.yearlyMinutes {
                            ServiceDetailRow(
                                icon: "calendar.badge.clock",
                                title: "Yearly Minutes",
                                value: "\(yearlyMinutes) minutes",
                                color: .pink
                            )
                        }
                        
                        ServiceDetailRow(
                            icon: "person.fill",
                            title: "Service Provider",
                            value: service.provider,
                            color: .teal
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Service Details")
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

struct DetailedNeedView: View {
    let need: AdditionalNeed
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Need Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(need.priority.color.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(need.priority.color)
                        }
                        
                        VStack(spacing: 8) {
                            Text(need.area)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text(need.priority.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(need.priority.color.opacity(0.1))
                                .foregroundColor(need.priority.color)
                                .cornerRadius(12)
                        }
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Description")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(need.description)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(12)
                    
                    // Strategies
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommended Strategies")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(need.strategies.enumerated()), id: \.offset) { index, strategy in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .background(need.priority.color)
                                        .clipShape(Circle())
                                    
                                    Text(strategy)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6).opacity(0.3))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Support Need Details")
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

struct ServiceDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(12)
    }
}

// MARK: - Service Summary View
struct ServiceSummaryView: View {
    let categories: [ServiceCategory]
    @Environment(\.dismiss) private var dismiss
    
    var totalCurrentServices: Int {
        categories.flatMap { $0.currentServices }.count
    }
    
    var totalAdditionalNeeds: Int {
        categories.flatMap { $0.additionalNeeds }.count
    }
    
    var totalWeeklyMinutes: Int {
        categories.flatMap { $0.currentServices }.reduce(0) { $0 + $1.weeklyMinutes }
    }
    
    var highPriorityNeeds: Int {
        categories.flatMap { $0.additionalNeeds }.filter { $0.priority == .high }.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Overall Stats
                    VStack(spacing: 20) {
                        Text("Service Overview")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 20) {
                            SummaryStatCard(
                                title: "Current Services",
                                value: "\(totalCurrentServices)",
                                subtitle: "Active",
                                color: .green,
                                icon: "checkmark.circle.fill"
                            )
                            
                            SummaryStatCard(
                                title: "Weekly Minutes",
                                value: "\(totalWeeklyMinutes)",
                                subtitle: "Total Time",
                                color: .blue,
                                icon: "clock.fill"
                            )
                        }
                        
                        HStack(spacing: 20) {
                            SummaryStatCard(
                                title: "Additional Needs",
                                value: "\(totalAdditionalNeeds)",
                                subtitle: "Identified",
                                color: .orange,
                                icon: "plus.circle.fill"
                            )
                            
                            SummaryStatCard(
                                title: "High Priority",
                                value: "\(highPriorityNeeds)",
                                subtitle: "Urgent Needs",
                                color: .red,
                                icon: "exclamationmark.triangle.fill"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(16)
                    
                    // Service Categories Summary
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Service Categories")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            ForEach(categories, id: \.id) { category in
                                CategorySummaryRow(category: category)
                            }
                        }
                    }
                    
                    // Key Recommendations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Key Recommendations")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            RecommendationCard(
                                title: "Communication Services",
                                recommendation: "Current speech services may need expansion to address significant language deficits",
                                priority: .high
                            )
                            
                            RecommendationCard(
                                title: "Behavioral Support",
                                recommendation: "New behavioral intervention services needed for social-emotional regulation",
                                priority: .high
                            )
                            
                            RecommendationCard(
                                title: "Sensory Support",
                                recommendation: "Increase OT consultation for comprehensive sensory processing support",
                                priority: .high
                            )
                            
                            RecommendationCard(
                                title: "Academic Accommodations",
                                recommendation: "Implement structured academic support strategies across all subjects",
                                priority: .medium
                            )
                        }
                    }
                    
                    // Eligibility Note
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Eligibility Status")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("The student meets eligibility criteria for Autism, with educational performance primarily affected by emotional disturbance. The IEP team will make final decisions on special education eligibility and educational programming.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding()
            }
            .navigationTitle("Service Summary")
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

struct SummaryStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CategorySummaryRow: View {
    let category: ServiceCategory
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundColor(category.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 8) {
                    Text("\(category.currentServices.count) current")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                    
                    Text("\(category.additionalNeeds.count) needed")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            Text(category.overallStatus.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(category.overallStatus.color.opacity(0.1))
                .foregroundColor(category.overallStatus.color)
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(12)
    }
}

struct RecommendationCard: View {
    let title: String
    let recommendation: String
    let priority: Priority
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(priority.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(priority.color.opacity(0.1))
                    .foregroundColor(priority.color)
                    .cornerRadius(6)
            }
            
            Text(recommendation)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(priority.color.opacity(0.05))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(priority.color.opacity(0.2), lineWidth: 1)
        )
    }
}
