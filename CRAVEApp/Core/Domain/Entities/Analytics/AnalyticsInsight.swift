import SwiftUI

public struct AnalyticsInsights: View {
    public let data: [String: Int]

    public init(data: [String: Int]) {
        self.data = data
    }

    public var body: some View {
        VStack {
            ForEach(data.keys.sorted(), id: \.self) { key in
                Text("\(key): \(data[key] ?? 0)")
                    .font(.caption)
            }
        }
    }
}
