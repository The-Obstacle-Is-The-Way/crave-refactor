// DateListView.swift

import SwiftUI
import SwiftData

public struct DateListView: View {
    @Query(sort: \CravingModel.timestamp, order: .reverse) public var cravings: [CravingModel]
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(cravings) { craving in
                    Text("\(craving.timestamp, formatter: Self.dateFormatter)")
                }
            }
            .navigationTitle("Dates")
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
}

struct DateListView_Previews: PreviewProvider {
    public static var previews: some View {
        DateListView()
    }
}
