// TimeOfDayPieChart.swift

import SwiftUI

struct TimeOfDayPieChart: View {
    let data: [String: Int]
    
    var body: some View {
        GeometryReader { geometry in
            let total = data.values.reduce(0, +)
            let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
            let radius = min(geometry.size.width, geometry.size.height) / 2
            ZStack {
                var startAngle = Angle(degrees: -90)
                ForEach(Array(data.keys.sorted()), id: \.self) { key in
                    let value = data[key] ?? 0
                    let proportion = total > 0 ? Double(value) / Double(total) : 0
                    let degrees = proportion * 360
                    let endAngle = startAngle + Angle(degrees: degrees)
                    
                    PieSlice(startAngle: startAngle, endAngle: endAngle)
                        .fill(color(for: key))
                    
                    startAngle = endAngle
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

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
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
    static var previews: some View {
        TimeOfDayPieChart(data: ["Morning": 3, "Afternoon": 2, "Evening": 4, "Night": 1])
            .frame(width: 200, height: 200)
            .padding()
    }
}
