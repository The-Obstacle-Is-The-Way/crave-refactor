//
//  🍒
//  CRAVEApp/Screens/AnalyticsDashboard/Components/CalendarHeatmapView.swift
//  Purpose:
//
//


import SwiftUI

struct CalendarHeatmapView: View {
    let data: [Date: Int]
    private let calendar = Calendar.current
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if data.isEmpty {
                Text("No data available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                LazyVGrid(columns: gridColumns, spacing: 4) {
                    ForEach(data.keys.sorted(), id: \.self) { date in
                        let count = data[date] ?? 0
                        Rectangle()
                            .fill(colorForCount(count))
                            .frame(height: 20)
                            .cornerRadius(4)
                            .overlay(
                                Text("\(count)")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white)
                                    .opacity(count > 0 ? 1 : 0)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .help("\(formatDate(date)): \(count) cravings")
                    }
                }
                
                // Legend
                HStack(spacing: 12) {
                    ForEach(0...3, id: \.self) { level in
                        HStack(spacing: 4) {
                            Rectangle()
                                .fill(colorForCount(level))
                                .frame(width: 12, height: 12)
                                .cornerRadius(2)
                            Text(legendLabel(for: level))
                                .font(.caption2)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return .gray.opacity(0.2)
        case 1: return .blue.opacity(0.4)
        case 2: return .blue.opacity(0.6)
        case 3: return .blue.opacity(0.8)
        default: return .blue
        }
    }
    
    private func legendLabel(for level: Int) -> String {
        switch level {
        case 0: return "None"
        case 1: return "Low"
        case 2: return "Medium"
        case 3: return "High"
        default: return "Very High"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    CalendarHeatmapView(data: {
        var data = [Date: Int]()
        let calendar = Calendar.current
        let today = Date()
        for offset in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                data[date] = Int.random(in: 0...4)
            }
        }
        return data
    }())
}
