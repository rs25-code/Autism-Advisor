//
//  SummaryTabView.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI

struct SummaryTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 16) {
            // AI Summary
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("AI Analysis Summary")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Text(appState.currentIEP?.summary ?? "No summary available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .frame(maxWidth: .infinity)
            
            // Progress Charts Section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                    Text("Goal Progress Overview")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                VStack(spacing: 20) {
                    ForEach(Array((appState.currentIEP?.goals ?? []).enumerated()), id: \.offset) { index, goal in
                        AnimatedBarChart(
                            title: goal.area,
                            status: goal.status,
                            progress: goal.progress
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .frame(maxWidth: .infinity)
            
            // Strengths
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    Text("Strengths Identified")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(appState.currentIEP?.strengths ?? [], id: \.self) { strength in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                                .padding(.top, 2)
                            
                            Text(strength)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            // Concerns
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                    Text("Areas of Concern")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(appState.currentIEP?.concerns ?? [], id: \.self) { concern in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                                .padding(.top, 2)
                            
                            Text(concern)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
    }
}

struct YearlyData {
    let year: String
    let value: Int
}

struct AnimatedBarChart: View {
    let title: String
    let status: IEPGoal.GoalStatus
    let progress: Int
    
    @State private var animatedValues: [Double] = [0, 0, 0]
    @State private var hasAnimated = false
    
    private var chartColor: Color {
        switch title.lowercased() {
        case let t where t.contains("reading"):
            return .blue
        case let t where t.contains("math"):
            return .purple
        case let t where t.contains("social"):
            return .green
        default:
            return .orange
        }
    }
    
    private var chartIcon: String {
        switch title.lowercased() {
        case let t where t.contains("reading"):
            return "book.fill"
        case let t where t.contains("math"):
            return "number.square.fill"
        case let t where t.contains("social"):
            return "person.2.fill"
        default:
            return "target"
        }
    }
    
    private var goalTarget: Int {
        switch title.lowercased() {
        case let t where t.contains("reading"):
            return 70
        case let t where t.contains("math"):
            return 60
        case let t where t.contains("social"):
            return 75
        default:
            return 65
        }
    }
    
    private var yearlyData: [YearlyData] {
        switch title.lowercased() {
        case let t where t.contains("reading"):
            return [
                YearlyData(year: "2023", value: 45),
                YearlyData(year: "2024", value: 62),
                YearlyData(year: "2025", value: 75)
            ]
        case let t where t.contains("math"):
            return [
                YearlyData(year: "2023", value: 25),
                YearlyData(year: "2024", value: 38),
                YearlyData(year: "2025", value: 45)
            ]
        case let t where t.contains("social"):
            return [
                YearlyData(year: "2023", value: 55),
                YearlyData(year: "2024", value: 72),
                YearlyData(year: "2025", value: 80)
            ]
        default:
            return [
                YearlyData(year: "2023", value: 40),
                YearlyData(year: "2024", value: 55),
                YearlyData(year: "2025", value: 70)
            ]
        }
    }
    
    private let maxValue: Double = 100
    private let chartHeight: CGFloat = 120
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: chartIcon)
                        .foregroundColor(chartColor)
                        .font(.title3)
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: status.icon)
                        .foregroundColor(status.color)
                        .font(.caption)
                    Text(status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(status.color.opacity(0.15))
                        .foregroundColor(status.color)
                        .cornerRadius(8)
                }
            }
            
            // 3-Year Progress Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("3-Year Progress History")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Bar Chart with Goal Line
                ZStack {
                    // Bar Chart
                    HStack(alignment: .bottom, spacing: 20) {
                        ForEach(Array(yearlyData.enumerated()), id: \.offset) { index, data in
                            VStack(spacing: 8) {
                                // Value label on top of bar with goal indicator
                                HStack(spacing: 2) {
                                    Text("\(Int(animatedValues[index]))%")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(chartColor)
                                    
                                    // Goal achievement indicator
                                    if animatedValues[index] >= Double(goalTarget) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                    } else if animatedValues[index] > 0 {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.caption2)
                                            .foregroundColor(.orange)
                                    }
                                }
                                .opacity(animatedValues[index] > 0 ? 1 : 0)
                                .animation(
                                    .easeInOut(duration: 0.3)
                                    .delay(Double(index) * 0.2 + 0.5),
                                    value: animatedValues[index]
                                )
                                
                                // Animated Bar
                                ZStack(alignment: .bottom) {
                                    // Background bar
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(.systemGray5))
                                        .frame(width: 40, height: chartHeight)
                                    
                                    // Animated progress bar with conditional coloring
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                colors: animatedValues[index] >= Double(goalTarget) ? [
                                                    chartColor.opacity(0.7),
                                                    chartColor,
                                                    chartColor.opacity(0.9)
                                                ] : [
                                                    chartColor.opacity(0.4),
                                                    chartColor.opacity(0.6),
                                                    chartColor.opacity(0.5)
                                                ],
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                        .frame(
                                            width: 40,
                                            height: max(4, (animatedValues[index] / maxValue) * chartHeight)
                                        )
                                        .animation(
                                            .spring(response: 1.2, dampingFraction: 0.8)
                                            .delay(Double(index) * 0.2),
                                            value: animatedValues[index]
                                        )
                                    
                                    // Shine effect
                                    if animatedValues[index] > 0 {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.4),
                                                        Color.clear
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(
                                                width: 40,
                                                height: max(4, (animatedValues[index] / maxValue) * chartHeight)
                                            )
                                    }
                                }
                                
                                // Year label
                                Text(data.year)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    // Goal line (dashed horizontal line)
                    GeometryReader { geometry in
                        let goalY = chartHeight - (CGFloat(goalTarget) / CGFloat(maxValue)) * chartHeight
                        
                        ZStack {
                            // Dashed line spanning the full width of bars
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: goalY))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: goalY))
                            }
                            .stroke(
                                chartColor.opacity(0.8),
                                style: StrokeStyle(
                                    lineWidth: 2.5,
                                    dash: [8, 4]
                                )
                            )
                            
                            // Goal label positioned at the right end
                            HStack {
                                Spacer()
                                Text("Goal: \(goalTarget)%")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(chartColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(.systemBackground))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(chartColor.opacity(0.4), lineWidth: 1.5)
                                            )
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    )
                            }
                            .offset(y: goalY - 12)
                        }
                    }
                }
                .frame(height: chartHeight + 40)
                
                // Progress indicators with goal status
                HStack {
                    Text("Baseline: \(yearlyData.first?.value ?? 0)%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    
                    // Goal achievement status
                    let currentValue = yearlyData.last?.value ?? 0
                    if currentValue >= goalTarget {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                            Text("Goal Achieved!")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            Text("\(goalTarget - currentValue)% to goal")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(chartColor.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(chartColor.opacity(0.2), lineWidth: 1)
                )
        )
        .onAppear {
            if !hasAnimated {
                hasAnimated = true
                startAnimation()
            }
        }
    }
    
    private func startAnimation() {
        for (index, data) in yearlyData.enumerated() {
            let delay = Double(index) * 0.3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                    animatedValues[index] = Double(data.value)
                }
            }
        }
    }
}
