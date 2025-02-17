//  CRAVEApp/Core/Presentation/Views/Analytics/CalendarHeatmapView.swift

import SwiftUI
import Charts

struct CalendarHeatmapView: View {
    let data: [Date: Int]
    private let calendar = Calendar.current
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(alignment:.leading, spacing: 8) {
            if data.isEmpty {
                Text("No data available")
                  .font(.caption)
                  .foregroundColor(.secondary)
                  .padding()
            } else {
                LazyVGrid(columns: gridColumns, spacing: 4) {
                    ForEach(data.keys.sorted(), id: \.self) { date in
                        CravingDayCell(count: data[date]?? 0, date: date)
                    }
                }

                HStack(spacing: 12) {
                    ForEach(0...3, id: \.self) { level in
                        LegendItem(level: level)
                    }
                }
              .padding(.top, 8)
            }
        }
    }

    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return.gray.opacity(0.2)
        case 1: return.blue.opacity(0.4)
        case 2: return.blue.opacity(0.6)
        case 3: return.blue.opacity(0.8)
        default: return.blue
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle =.medium
        return formatter.string(from: date)
    }
}

struct LegendItem: View {
    let level: Int

    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return.gray.opacity(0.2)
        case 1: return.blue.opacity(0.4)
        case 2: return.blue.opacity(0.6)
        case 3: return.blue.opacity(0.8)
        default: return.blue
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
