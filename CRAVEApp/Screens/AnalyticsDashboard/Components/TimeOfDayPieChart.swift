// TimeOfDayPieChart.swift

import SwiftUI

public struct TimeOfDayPieChart: View {
    let data: [String: Int]
    
    public init(data: [String: Int]) {
        self.data = data
    }
    
    // Define a slice model for the pie chart.
    struct Slice: Identifiable {
        let id = UUID()
        let key: String
        let startAngle: Angle
        let endAngle: Angle
    }
    
    // Compute slices from the input dictionary.
    var slices: [Slice] {
        var slices = [Slice]()
        let total = data.values.reduce(0, +)
        var currentAngle = Angle(degrees: -90)
        for key in data.keys.sorted() {
            let value = data[key] ?? 0
            let proportion = total > 0 ? Double(value) / Double(total) : 0
            let angleDelta = Angle(degrees: proportion * 360)
            let slice = Slice(key: key, startAngle: currentAngle, endAngle: currentAngle + angleDelta)
            slices.append(slice)
            currentAngle += angleDelta
        }
        return slices
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
            ZStack {
                ForEach(slices) { slice in
                    PieSlice(startAngle: slice.startAngle, endAngle: slice.endAngle)
                        .fill(color(for: slice.key))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .position(x: center.x, y: center.y)
        }
    }
    
    private func color(for key: String) -> Color {
        switch key {
        case "Morning": return .yellow
        case "Afternoon": return .orange
        case "Evening": return .red
        case "Night": return .blue
        default: return .gray
        }
    }
}

public struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    public func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct TimeOfDayPieChart_Previews: PreviewProvider {
    public static var previews: some View {
        TimeOfDayPieChart(data: ["Morning": 3, "Afternoon": 2, "Evening": 4, "Night": 1])
            .frame(width: 200, height: 200)
            .padding()
    }
}
