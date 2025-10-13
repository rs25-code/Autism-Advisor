//
//  TeamCommunicationScreen.swift
//  Autism
//
//  Created by Rhea Sreedhar on 9/12/25.
//

import SwiftUI

struct TeamCommunicationScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTopic: CommunicationTopic? = nil
    @State private var selectedRole = TeamRole.teacher
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    teamMembersSection
                    communicationTopicsSection
                    meetingPreparationSection
                    advocacySection
                    resourcesSection
                }
                .padding()
            }
            .navigationTitle("Team Communication")
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
        .sheet(item: $selectedTopic) { topic in
            CommunicationTopicDetailView(topic: topic)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "message.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                Text("Effective Team Communication")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Build strong partnerships with your child's educational team")
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
    
    // MARK: - Team Members Section
    private var teamMembersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Child's Team")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Understanding each team member's role helps you communicate more effectively:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                ForEach(TeamRole.allCases, id: \.self) { role in
                    TeamMemberCard(role: role)
                }
            }
        }
    }
    
    // MARK: - Communication Topics Section
    private var communicationTopicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Common Communication Topics")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(CommunicationTopic.allCases, id: \.self) { topic in
                    CommunicationTopicCard(topic: topic) {
                        selectedTopic = topic
                    }
                }
            }
        }
    }
    
    // MARK: - Meeting Preparation Section
    private var meetingPreparationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("IEP Meeting Preparation")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                PreparationStepCard(
                    step: 1,
                    title: "Review Current IEP",
                    description: "Understand current goals, services, and your child's progress",
                    icon: "doc.text.magnifyingglass"
                )
                
                PreparationStepCard(
                    step: 2,
                    title: "Gather Documentation",
                    description: "Collect work samples, progress reports, and outside evaluations",
                    icon: "folder.fill"
                )
                
                PreparationStepCard(
                    step: 3,
                    title: "Prepare Questions",
                    description: "Write down concerns, questions, and goals for the meeting",
                    icon: "questionmark.circle.fill"
                )
                
                PreparationStepCard(
                    step: 4,
                    title: "Know Your Rights",
                    description: "Understand your rights as a parent in the IEP process",
                    icon: "shield.fill"
                )
            }
        }
    }
    
    // MARK: - Advocacy Section
    private var advocacySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Effective Advocacy Tips")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                AdvocacyTipCard(
                    icon: "person.2.fill",
                    title: "Build Relationships",
                    description: "Establish positive relationships with team members throughout the year, not just during meetings"
                )
                
                AdvocacyTipCard(
                    icon: "doc.text.fill",
                    title: "Document Everything",
                    description: "Keep records of all communications, meetings, and your child's progress"
                )
                
                AdvocacyTipCard(
                    icon: "lightbulb.fill",
                    title: "Stay Solution-Focused",
                    description: "Come prepared with specific suggestions and potential solutions, not just problems"
                )
                
                AdvocacyTipCard(
                    icon: "heart.fill",
                    title: "Share Your Child's Strengths",
                    description: "Help the team see your child's abilities, interests, and positive qualities"
                )
                
                AdvocacyTipCard(
                    icon: "ear.fill",
                    title: "Listen Actively",
                    description: "Show respect for team members' expertise while advocating for your child's needs"
                )
            }
        }
    }
    
    // MARK: - Resources Section
    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Communication Resources")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ResourceCard(
                    title: "PACER Center",
                    description: "Parent advocacy and training resources",
                    url: "https://www.pacer.org/parent/",
                    icon: "megaphone.fill",
                    color: .blue
                )
                
                ResourceCard(
                    title: "Center for Parent Information",
                    description: "State-by-state parent training centers",
                    url: "https://www.parentcenterhub.org/find-your-center/",
                    icon: "location.fill",
                    color: .green
                )
                
                ResourceCard(
                    title: "Wrightslaw",
                    description: "Special education law and advocacy training",
                    url: "https://www.wrightslaw.com/",
                    icon: "scale.3d",
                    color: .purple
                )
                
                ResourceCard(
                    title: "IEP Meeting Prep Worksheet",
                    description: "Printable meeting preparation checklist",
                    url: "https://www.understood.org/en/school-learning/special-services/ieps/iep-meeting-worksheet",
                    icon: "checklist",
                    color: .orange
                )
            }
        }
    }
}

// MARK: - Supporting Models
enum TeamRole: String, CaseIterable {
    case teacher = "General Education Teacher"
    case specialEducationTeacher = "Special Education Teacher"
    case principal = "Principal/Administrator"
    case schoolPsychologist = "School Psychologist"
    case speechTherapist = "Speech-Language Pathologist"
    case occupationalTherapist = "Occupational Therapist"
    case physicalTherapist = "Physical Therapist"
    case socialWorker = "School Social Worker"
    case counselor = "School Counselor"
    
    var icon: String {
        switch self {
        case .teacher: return "graduationcap.fill"
        case .specialEducationTeacher: return "person.fill.questionmark"
        case .principal: return "building.2.fill"
        case .schoolPsychologist: return "brain.head.profile"
        case .speechTherapist: return "message.fill"
        case .occupationalTherapist: return "hand.raised.fill"
        case .physicalTherapist: return "figure.walk"
        case .socialWorker: return "heart.fill"
        case .counselor: return "person.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .teacher: return .blue
        case .specialEducationTeacher: return .purple
        case .principal: return .red
        case .schoolPsychologist: return .green
        case .speechTherapist: return .orange
        case .occupationalTherapist: return .cyan
        case .physicalTherapist: return .mint
        case .socialWorker: return .pink
        case .counselor: return .yellow
        }
    }
    
    var description: String {
        switch self {
        case .teacher:
            return "Implements accommodations and modifications in the general education classroom"
        case .specialEducationTeacher:
            return "Provides specialized instruction and supports IEP goal development"
        case .principal:
            return "Ensures school compliance with IEP requirements and allocates resources"
        case .schoolPsychologist:
            return "Conducts evaluations and provides behavioral and academic interventions"
        case .speechTherapist:
            return "Addresses communication, language, and social communication goals"
        case .occupationalTherapist:
            return "Supports fine motor skills, sensory needs, and adaptive equipment"
        case .physicalTherapist:
            return "Addresses gross motor skills and mobility needs"
        case .socialWorker:
            return "Provides counseling services and connects families with community resources"
        case .counselor:
            return "Supports academic planning, career guidance, and social-emotional needs"
        }
    }
}

enum CommunicationTopic: String, CaseIterable, Identifiable {
    case progress = "Progress Updates"
    case concerns = "Addressing Concerns"
    case goals = "Goal Development"
    case services = "Service Changes"
    case placement = "Placement Decisions"
    case transition = "Transition Planning"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .progress: return "chart.line.uptrend.xyaxis"
        case .concerns: return "exclamationmark.triangle.fill"
        case .goals: return "target"
        case .services: return "person.3.fill"
        case .placement: return "building.2.fill"
        case .transition: return "arrow.right.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .progress: return .green
        case .concerns: return .red
        case .goals: return .blue
        case .services: return .orange
        case .placement: return .purple
        case .transition: return .cyan
        }
    }
    
    var description: String {
        switch self {
        case .progress: return "Discussing your child's academic and behavioral progress"
        case .concerns: return "Addressing challenges and developing solutions"
        case .goals: return "Creating meaningful and measurable IEP goals"
        case .services: return "Evaluating and adjusting special education services"
        case .placement: return "Determining the most appropriate educational setting"
        case .transition: return "Planning for transitions between grades or programs"
        }
    }
}

// MARK: - Supporting Views
struct TeamMemberCard: View {
    let role: TeamRole
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: role.icon)
                .font(.title3)
                .foregroundColor(role.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(role.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(role.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(role.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(role.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct CommunicationTopicCard: View {
    let topic: CommunicationTopic
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: topic.icon)
                    .font(.title2)
                    .foregroundColor(topic.color)
                
                VStack(spacing: 4) {
                    Text(topic.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text(topic.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
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

struct PreparationStepCard: View {
    let step: Int
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 32, height: 32)
                
                Text("\(step)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
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
                    .fixedSize(horizontal: false, vertical: true)
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

struct AdvocacyTipCard: View {
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
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.3))
        )
    }
}

// ResourceCard struct is defined in UnderstandingIEPsScreen.swift

// MARK: - Communication Topic Detail View
struct CommunicationTopicDetailView: View {
    let topic: CommunicationTopic
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    detailContent
                }
                .padding()
            }
            .navigationTitle(topic.rawValue)
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
        switch topic {
        case .progress:
            progressContent
        case .concerns:
            concernsContent
        case .goals:
            goalsContent
        case .services:
            servicesContent
        case .placement:
            placementContent
        case .transition:
            transitionContent
        }
    }
    
    private var progressContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Discussing Progress Updates")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Regular progress monitoring is essential for your child's success. Here's how to have productive conversations about progress:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                CommunicationPoint(title: "Ask Specific Questions", description: "Instead of 'How is my child doing?', ask 'What specific progress has been made on the reading comprehension goal this quarter?'")
                
                CommunicationPoint(title: "Request Data", description: "Ask to see work samples, assessment results, and data collection that shows progress toward IEP goals.")
                
                CommunicationPoint(title: "Share Home Observations", description: "Provide insights about skills or challenges you observe at home that may not be evident at school.")
                
                CommunicationPoint(title: "Discuss Next Steps", description: "If progress is insufficient, work together to modify strategies or adjust goals as needed.")
            }
            
            Text("Sample Questions to Ask:")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                BulletPointView(text: "What specific data shows my child's progress on each IEP goal?")
                BulletPointView(text: "Which strategies are working best in the classroom?")
                BulletPointView(text: "Are there any goals that need to be modified?")
                BulletPointView(text: "How can I support this progress at home?")
            }
        }
    }
    
    private var concernsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Addressing Concerns Effectively")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("When you have concerns about your child's education, approach discussions constructively:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                CommunicationPoint(title: "Document Concerns", description: "Write down specific behaviors, incidents, or patterns you've observed, including dates and contexts.")
                
                CommunicationPoint(title: "Be Specific", description: "Instead of 'My child is struggling,' say 'My child is having difficulty with math word problems and becomes frustrated after 10 minutes.'")
                
                CommunicationPoint(title: "Come with Solutions", description: "Suggest potential strategies or accommodations that might help address the concern.")
                
                CommunicationPoint(title: "Stay Collaborative", description: "Frame concerns as opportunities to work together rather than accusations or complaints.")
            }
            
            Text("Effective Concern Communication:")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                BulletPointView(text: "'I've noticed... and I'm wondering if we could explore...'")
                BulletPointView(text: "'Could we discuss strategies to help with...'")
                BulletPointView(text: "'I'd like to understand why... is happening'")
                BulletPointView(text: "'What would you recommend for addressing...'")
            }
        }
    }
    
    private var goalsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Developing Meaningful IEP Goals")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("IEP goals should be specific, measurable, and directly related to your child's needs:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                CommunicationPoint(title: "Focus on Functional Skills", description: "Ensure goals address skills your child needs for academic and life success.")
                
                CommunicationPoint(title: "Make Them Measurable", description: "Goals should have clear criteria for measuring progress (e.g., '4 out of 5 trials,' 'with 80% accuracy').")
                
                CommunicationPoint(title: "Consider All Environments", description: "Goals should address skills needed across home, school, and community settings.")
                
                CommunicationPoint(title: "Think Long-term", description: "Connect annual goals to your child's post-secondary aspirations and transition needs.")
            }
            
            Text("Questions for Goal Development:")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                BulletPointView(text: "What skills does my child need most for success?")
                BulletPointView(text: "How will we measure progress on this goal?")
                BulletPointView(text: "What supports will be needed to achieve this goal?")
                BulletPointView(text: "How does this goal connect to post-secondary goals?")
            }
        }
    }
    
    private var servicesContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Evaluating Special Education Services")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Regularly review whether current services are meeting your child's needs:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                CommunicationPoint(title: "Review Service Delivery", description: "Discuss whether the frequency, duration, and location of services are appropriate.")
                
                CommunicationPoint(title: "Assess Effectiveness", description: "Examine whether current services are helping your child make progress toward IEP goals.")
                
                CommunicationPoint(title: "Consider Additional Needs", description: "Discuss whether your child needs additional or different related services.")
                
                CommunicationPoint(title: "Plan for Changes", description: "Be prepared to advocate for service increases, decreases, or modifications based on your child's needs.")
            }
        }
    }
    
    private var placementContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Discussing Placement Decisions")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Educational placement should be based on your child's individual needs and the principle of least restrictive environment:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                CommunicationPoint(title: "Understand LRE", description: "Your child should be educated with typical peers to the maximum extent appropriate with necessary supports.")
                
                CommunicationPoint(title: "Evaluate Current Placement", description: "Discuss whether your child is making progress and accessing the general curriculum in their current setting.")
                
                CommunicationPoint(title: "Consider All Options", description: "Explore different placement options and the continuum of services available.")
                
                CommunicationPoint(title: "Focus on Outcomes", description: "The goal is the placement where your child can make meaningful progress toward their IEP goals.")
            }
        }
    }
    
    private var transitionContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Planning for Transitions")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Transitions between grades, schools, or programs require careful planning and communication:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 12) {
                CommunicationPoint(title: "Start Early", description: "Begin transition planning well in advance to ensure smooth continuity of services.")
                
                CommunicationPoint(title: "Share Information", description: "Ensure that receiving teachers/schools have comprehensive information about your child's needs and successful strategies.")
                
                CommunicationPoint(title: "Plan Visits", description: "Arrange for your child to visit new environments and meet new team members when possible.")
                
                CommunicationPoint(title: "Monitor Adjustment", description: "Stay in close communication during the transition period to address any challenges quickly.")
            }
        }
    }
}

struct CommunicationPoint: View {
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

struct BulletPointView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.orange)
                .fontWeight(.bold)
            
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview
struct TeamCommunicationScreen_Previews: PreviewProvider {
    static var previews: some View {
        TeamCommunicationScreen()
    }
}
