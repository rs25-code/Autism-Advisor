//
//  UnderstandingIEPsScreen.swift
//  Autism
//
//  Created by AI Assistant on 9/12/25.
//

import SwiftUI

struct UnderstandingIEPsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection: IEPSection? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    whatIsIEPSection
                    keyComponentsSection
                    rightsSection
                    resourcesSection
                }
                .padding()
            }
            .navigationTitle("Understanding IEPs")
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
        .sheet(item: $selectedSection) { section in
            IEPSectionDetailView(section: section)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "book.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                Text("Your Guide to IEPs")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Everything you need to know about your child's Individualized Education Program")
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
    
    // MARK: - What is an IEP Section
    private var whatIsIEPSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What is an IEP?")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("An Individualized Education Program (IEP) is a legally binding document that outlines the special education services your child will receive. It's designed specifically for your child's unique needs and is reviewed annually.")
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 12) {
                IEPFactCard(
                    icon: "person.fill",
                    title: "Individualized",
                    description: "Tailored to your child's specific needs and strengths",
                    color: .blue
                )
                
                IEPFactCard(
                    icon: "scale.3d",
                    title: "Legally Binding",
                    description: "School must provide all services listed in the IEP",
                    color: .green
                )
                
                IEPFactCard(
                    icon: "arrow.clockwise",
                    title: "Regularly Updated",
                    description: "Reviewed at least once per year and updated as needed",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Key Components Section
    private var keyComponentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key IEP Components")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Understanding these essential parts will help you navigate your child's IEP more effectively:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(IEPComponent.allCases, id: \.self) { component in
                    IEPComponentCard(component: component) {
                        selectedSection = IEPSection(component: component)
                    }
                }
            }
        }
    }
    
    // MARK: - Rights Section
    private var rightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Rights as a Parent")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ParentRightCard(
                    icon: "eye.fill",
                    title: "Right to Participate",
                    description: "You are an equal member of the IEP team and have the right to participate in all decisions"
                )
                
                ParentRightCard(
                    icon: "doc.text.magnifyingglass",
                    title: "Access to Records",
                    description: "You can review your child's educational records and request copies"
                )
                
                ParentRightCard(
                    icon: "person.2.fill",
                    title: "Independent Evaluation",
                    description: "You can request an independent educational evaluation if you disagree with the school's assessment"
                )
                
                ParentRightCard(
                    icon: "exclamationmark.shield.fill",
                    title: "Due Process",
                    description: "You have the right to resolve disputes through mediation or due process hearings"
                )
            }
        }
    }
    
    // MARK: - Resources Section
    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Helpful Resources")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ResourceCard(
                    title: "Autism Speaks",
                    description: "IEP guide and advocacy resources",
                    url: "https://www.autismspeaks.org/tool-kit/100-day-kit/iep-guide",
                    icon: "link.circle.fill",
                    color: .blue
                )
                
                ResourceCard(
                    title: "Understood.org",
                    description: "IEP basics and parent guides",
                    url: "https://www.understood.org/en/school-learning/special-services/ieps",
                    icon: "link.circle.fill",
                    color: .green
                )
                
                ResourceCard(
                    title: "Center for Parent Resources",
                    description: "Training and information for parents",
                    url: "https://www.parentcenterhub.org/iep/",
                    icon: "link.circle.fill",
                    color: .orange
                )
                
                ResourceCard(
                    title: "Wright's Law",
                    description: "Special education law and advocacy",
                    url: "https://www.wrightslaw.com/info/iep.index.htm",
                    icon: "link.circle.fill",
                    color: .purple
                )
            }
        }
    }
}

// MARK: - Supporting Models
enum IEPComponent: String, CaseIterable {
    case presentLevels = "Present Levels"
    case goals = "Annual Goals"
    case services = "Special Education Services"
    case placement = "Least Restrictive Environment"
    case assessment = "Assessment Accommodations"
    case transition = "Transition Planning"
    
    var icon: String {
        switch self {
        case .presentLevels: return "chart.line.uptrend.xyaxis"
        case .goals: return "target"
        case .services: return "person.3.fill"
        case .placement: return "building.2.fill"
        case .assessment: return "checkmark.seal.fill"
        case .transition: return "arrow.right.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .presentLevels: return .blue
        case .goals: return .green
        case .services: return .orange
        case .placement: return .purple
        case .assessment: return .red
        case .transition: return .cyan
        }
    }
    
    var description: String {
        switch self {
        case .presentLevels: return "Your child's current academic and functional performance"
        case .goals: return "Measurable annual goals for improvement"
        case .services: return "Special education and related services provided"
        case .placement: return "Educational environment and inclusion opportunities"
        case .assessment: return "Testing modifications and accommodations"
        case .transition: return "Post-secondary goals and transition services"
        }
    }
}

struct IEPSection: Identifiable {
    let id = UUID()
    let component: IEPComponent
}

// MARK: - Supporting Views
struct IEPFactCard: View {
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
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct IEPComponentCard: View {
    let component: IEPComponent
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: component.icon)
                    .font(.title2)
                    .foregroundColor(component.color)
                
                VStack(spacing: 4) {
                    Text(component.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text(component.description)
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

struct ParentRightCard: View {
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
                .fill(Color.orange.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ResourceCard: View {
    let title: String
    let description: String
    let url: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.3))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Detail View
struct IEPSectionDetailView: View {
    let section: IEPSection
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    detailContent
                }
                .padding()
            }
            .navigationTitle(section.component.rawValue)
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
        switch section.component {
        case .presentLevels:
            presentLevelsContent
        case .goals:
            goalsContent
        case .services:
            servicesContent
        case .placement:
            placementContent
        case .assessment:
            assessmentContent
        case .transition:
            transitionContent
        }
    }
    
    private var presentLevelsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Present Levels of Academic Achievement and Functional Performance (PLAAFP)")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("This section describes your child's current abilities and challenges. It serves as the foundation for setting appropriate goals and determining necessary services.")
                .font(.body)
            
            Text("What to Look For:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 8) {
                BulletPoint(text: "Specific, measurable descriptions of your child's current performance")
                BulletPoint(text: "Both strengths and areas of need")
                BulletPoint(text: "How the disability affects involvement in general education")
                BulletPoint(text: "Data from recent assessments and observations")
            }
        }
    }
    
    private var goalsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Annual Goals")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Goals should be SMART: Specific, Measurable, Achievable, Relevant, and Time-bound. They should directly address your child's needs identified in the present levels.")
                .font(.body)
            
            Text("Components of a Good Goal:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 8) {
                BulletPoint(text: "Clear description of what your child will accomplish")
                BulletPoint(text: "Measurable criteria for success")
                BulletPoint(text: "Timeline for achievement (usually one year)")
                BulletPoint(text: "Method for measuring progress")
            }
        }
    }
    
    private var servicesContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Special Education Services")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("This section outlines all special education and related services your child will receive, including frequency, duration, and location.")
                .font(.body)
            
            Text("Types of Services:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 8) {
                BulletPoint(text: "Special education instruction")
                BulletPoint(text: "Related services (speech, OT, PT, counseling)")
                BulletPoint(text: "Supplementary aids and services")
                BulletPoint(text: "Program modifications or supports")
            }
        }
    }
    
    private var placementContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Least Restrictive Environment (LRE)")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Your child should be educated with peers without disabilities to the maximum extent appropriate, with supplementary aids and services as needed.")
                .font(.body)
            
            Text("Placement Options (from least to most restrictive):")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 8) {
                BulletPoint(text: "General education classroom with supports")
                BulletPoint(text: "General education with resource room")
                BulletPoint(text: "Special education classroom in regular school")
                BulletPoint(text: "Special education school")
                BulletPoint(text: "Residential or home/hospital setting")
            }
        }
    }
    
    private var assessmentContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Assessment Accommodations")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Accommodations help level the playing field for your child during testing without changing what's being measured.")
                .font(.body)
            
            Text("Common Accommodations:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 8) {
                BulletPoint(text: "Extended time")
                BulletPoint(text: "Separate testing room")
                BulletPoint(text: "Test read aloud")
                BulletPoint(text: "Large print or digital format")
                BulletPoint(text: "Frequent breaks")
            }
        }
    }
    
    private var transitionContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transition Planning")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Beginning at age 16 (or earlier if appropriate), the IEP must include post-secondary goals and transition services to help your child prepare for life after high school.")
                .font(.body)
            
            Text("Transition Areas:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 8) {
                BulletPoint(text: "Post-secondary education or training")
                BulletPoint(text: "Employment and career preparation")
                BulletPoint(text: "Independent living skills")
                BulletPoint(text: "Community participation")
            }
        }
    }
}

struct BulletPoint: View {
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
struct UnderstandingIEPsScreen_Previews: PreviewProvider {
    static var previews: some View {
        UnderstandingIEPsScreen()
    }
}
