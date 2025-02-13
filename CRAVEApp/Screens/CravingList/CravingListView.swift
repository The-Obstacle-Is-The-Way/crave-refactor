// CravingListView.swift

import SwiftUI
import SwiftData

public struct CravingListView: View {
    @Query(sort: \CravingModel.timestamp, order: .reverse) public var cravings: [CravingModel]
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(cravings) { craving in
                    Text("Craving at \(craving.timestamp, formatter: Self.dateFormatter)")
                }
            }
            .navigationTitle("Cravings")
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

struct CravingListView_Previews: PreviewProvider {
    public static var previews: some View {
        // Provide a dummy ModelContainer for preview purposes.
        let container: ModelContainer
        do {
            container = try ModelContainer(for: Schema([CravingModel.self]))
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
        return CravingListView()
            .modelContainer(container)
    }
}
