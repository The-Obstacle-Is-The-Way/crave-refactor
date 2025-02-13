// CalendarHeatmapView.swift

import SwiftUI

struct CalendarHeatmapView: View {
    let data: [Date: Int]
    
    var body: some View {
        let sortedDates = data.keys.sorted()
        // Display in a 7-column grid (one week per row)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
        
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(sortedDates, id: \.self) { date in
                let count = data[date] ?? 0
                Rectangle()
                    .fill(color(for: count))
                    .frame(width: 20, height: 20)
                    .overlay(Text(shortDateString(from: date))
                                .font(.caption2)
                                .opacity(0)) // Hide text but keep layout consistent
            }
        }
    }
    
    private func color(for count: Int) -> Color {
        switch count {
        case 0: return Color.gray.opacity(0.2)
        case 1: return Color.green.opacity(0.4)
        case 2: return Color.green.opacity(0.6)
        case 3: return Color.green.opacity(0.8)
        default: return Color.green
        }
    }
    
    private func shortDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

struct CalendarHeatmapView_Previews: PreviewProvider {
    static var previews: some View {
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
        .padding()
    }
}
