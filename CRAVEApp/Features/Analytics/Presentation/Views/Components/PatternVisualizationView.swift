//
//
//  🍒
//  CRAVEApp/Features/Analytics/Presentation/Views/Components/PatternVisualizationView.swift
//  Purpose: A view that visualizes patterns in the user's data.
//
//

import SwiftUI
import Charts

struct PatternVisualizationView: View {
    let timeOfDayData: [String: Int]
    let patternData: [String: Double]

    var body: some View {
        VStack(spacing: 20) {
            Text("Time of Day Distribution")
                .font(CRAVEDesignSystem.Typography.headline) //UPDATE: headline
            
            TimeOfDayPieChart(data: timeOfDayData)
            
            Text("Pattern Strength")
                .font(CRAVEDesignSystem.Typography.headline) //UPDATE: headline
            
            // Additional pattern visualization components can go here
            
            if !patternData.isEmpty {
                Chart(patternData.sorted(by: { $0.key < $1.key }), id: \.key) { pattern, strength in
                    BarMark(
                        x: .value("Pattern", pattern),
                        y: .value("Strength", strength)
                    )
                }
                .frame(height: 200)
            }
        }
        .padding()
    }
}

#Preview {
    PatternVisualizationView(
        timeOfDayData: [
            "Morning": 3,
            "Afternoon": 5,
            "Evening": 2,
            "Night": 4
        ],
        patternData: [
            "Daily": 0.8,
            "Weekly": 0.6,
            "Monthly": 0.4
        ]
    )
}
