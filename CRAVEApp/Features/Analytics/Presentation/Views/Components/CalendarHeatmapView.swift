//
//
//  🍒
//  CRAVEApp/Features/Analytics/Presentation/Views/Components/CalendarHeatmapView.swift
//  Purpose: A calendar heatmap view for displaying data over time.
//
//


import SwiftUI
import Charts

struct CalendarHeatmapView: View {
    let data: [Date: Int]
    private let calendar = Calendar.current
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if data.isEmpty {
                Text("No data available")
                    .font(.caption) // Use .caption, not a custom one.
                    .foregroundColor(.secondary) // Use system colors
                    .padding()
            } else {
                LazyVGrid(columns: gridColumns, spacing: 4) {
                    ForEach(data.keys.sorted(), id: \.self) { date in
                        CravingDayCell(count: data[date] ?? 0, date: date) // Extract cell
                    }
                }

                // Legend
                HStack(spacing: 12) {
                    ForEach(0...3, id: \.self) { level in
                        LegendItem(level: level)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    //helper to calculate the color
    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return .gray.opacity(0.2)
        case 1: return .blue.opacity(0.4)
        case 2: return .blue.opacity(0.6)
        case 3: return .blue.opacity(0.8)
        default: return .blue
        }
    }
     //helper to format dates
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    //helper to format the legend
    private func legendLabel(for level: Int) -> String {
        switch level {
        case 0: return "None"
        case 1: return "Low"
        case 2: return "Medium"
        case 3: return "High"
        default: return "Very High"
        }
    }
}

// Extracted for clarity
struct CravingDayCell: View {
    let count: Int
    let date: Date

    var body: some View {
        Rectangle()
            .fill(colorForCount(count))
            .frame(height: 20)
            .cornerRadius(4)
            .overlay(
                Group { // Use Group for conditional content
                    if count > 0 {
                        Text("\(count)")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .accessibilityLabel("\(formatDate(date)): \(count) cravings") // Use accessibilityLabel for VoiceOver
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Extracted for clarity
struct LegendItem: View {
    let level: Int
    
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

    var body: some View {
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
