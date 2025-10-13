//
//  AnalysisScreen.swift
//  Autism
//
//  Created by Rhea Sreedhar on 8/4/25.
//

import SwiftUI

struct AnalysisScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var isRegenerating = false
      
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { appState.navigate(to: .dashboard) }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                  
                VStack(alignment: .leading) {
                    Text("Support Plan Analysis")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(appState.currentIEP?.studentName ?? "Student")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                HStack {
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.orange)
                    }
                      
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
              
            // Overall Score
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(appState.currentIEP?.overallScore ?? 85)%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                          
                        Text("Overall Support Plan Quality Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                      
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Last Updated")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("2 hours ago")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal)
              
            // Tabs
            Picker("Analysis Tabs", selection: $selectedTab) {
                Text("Summary").tag(0)
                Text("Goals").tag(1)
                Text("Services").tag(2)
                Text("Game Plan").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .accentColor(.orange)
              
            // Tab Content
            ScrollView {
                switch selectedTab {
                case 0:
                    SummaryTabView()
                        .frame(maxWidth: 800)
                        .frame(maxWidth: .infinity)
                case 1:
                    GoalsTabView()
                case 2:
                    ServicesTabView()
                case 3:
                    GamePlanTabView()
                default:
                    SummaryTabView()
                }
            }
              
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: handleRegenerate) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(isRegenerating ? 360 : 0))
                            .animation(isRegenerating ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRegenerating)
                        Text(isRegenerating ? "Regenerating..." : "Regenerate Analysis")
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(isRegenerating)
                  
                Button("Ask Questions About This Document") {
                    appState.navigate(to: .qa)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
        }
    }
      
    private func handleRegenerate() {
        isRegenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isRegenerating = false
        }
    }
}
