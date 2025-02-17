import SwiftUI

public struct CravingCard: View {
    public let craving: CravingEntity

    public init(craving: CravingEntity) {
        self.craving = craving
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(craving.text)
                .font(.headline)
            Text("\(craving.timestamp, formatter: dateFormatter)")
                .font(.caption)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

