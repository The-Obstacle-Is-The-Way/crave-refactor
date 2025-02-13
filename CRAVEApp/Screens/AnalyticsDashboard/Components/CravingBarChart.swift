//  CravingBarChart.swift

import SwiftUI

public struct CravingBarChart: View {
    let data: [Date: Int]
    
    public init(data: [Date: Int]) {
        self.data = data
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let sortedData = data.sorted { $0.key < $1.key }
            let maxCount = sortedData.map { $0.value }.max() ?? 1
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(sortedData, id: \.key) { (date, count) in
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(height: CGFloat(count) / CGFloat(maxCount) * geometry.size.height)
                        Text(shortDateString(from: date))
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
    
    private func shortDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

struct CravingBarChart_Previews: PreviewProvider {
    public static var previews: some View {
        CravingBarChart(data: {
            var data = [Date: Int]()
            let calendar = Calendar.current
            let today = Date()
            for offset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                    data[date] = Int.random(in: 0...5)
                }
            }
            return data
        }())
        .frame(height: 200)
        .padding()
    }
}
