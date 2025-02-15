//
//  🍒
//  CRAVEApp/Screens/AnalyticsDashboard/Components/CalendarHeatmapView.swift
//  Purpose:
//
//

import SwiftUI

public struct CalendarHeatmapView: View {
    let data: [Date: Int]

    public init(data: [Date: Int]) {
        self.data = data
    }

    public var body: some View {
        // We want to display a grid, with 7 columns (for days of the week)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        LazyVGrid(columns: columns, spacing: 4) {
            // We'll use ForEach to create a cell for each date
            ForEach(data.keys.sorted(), id: \.self) { date in
                // Get the count of cravings for the current date
                let count = data[date] ?? 0

                // Create a rectangle and fill it with a color based on the count
                Rectangle()
                    .fill(color(for: count))
                    .frame(width: 20, height: 20) // Adjust size as needed
                    .overlay(
                        Text(shortDateString(from: date)) // Display the day number
                            .font(.caption2)
                            .opacity(0) // Keep this invisible, used to help with layout
                    )
            }
        }
    }

    // Helper function to determine the color based on the craving count
    private func color(for count: Int) -> Color {
        switch count {
        case 0: return Color.gray.opacity(0.2) // Very light gray for no cravings
        case 1: return Color.green.opacity(0.4) // Light green for few cravings
        case 2: return Color.green.opacity(0.6) // Medium green
        case 3: return Color.green.opacity(0.8) // Darker green
        default: return Color.green // Darkest green for high number of cravings
        }
    }

    // Helper function to format the date and get just the day number
    private func shortDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d" // "d" gives us the day of the month (e.g., "1", "15")
        return formatter.string(from: date)
    }
}

// Preview provider for SwiftUI previews
struct CalendarHeatmapView_Previews: PreviewProvider {
    static var previews: some View {
        // Create some sample data for the preview.  This is the corrected part.
        CalendarHeatmapView(data: createSampleData())
            .padding()
    }

    static func createSampleData() -> [Date: Int] {
        var data = [Date: Int]()
        let calendar = Calendar.current
        let today = Date()
        for offset in 0..<30 { // Display data for the past 30 days
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                data[calendar.startOfDay(for: date)] = Int.random(in: 0...4) // Random craving count between 0 and 4, store the START of the day
            }
        }
        return data
    }
}
