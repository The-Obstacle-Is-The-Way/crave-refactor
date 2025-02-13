// DateListView.swift

import SwiftUI
import SwiftData

struct DateListView: View {
    @Query(sort: \CravingModel.timestamp, animation: .default)
    private var cravings: [CravingModel]
    
    var body: some View {
        let grouped = Dictionary(grouping: cravings, by: { $0.timestamp.onlyDate })
        return List {
            ForEach(grouped.keys.sorted(), id: \.self) { date in
                Section(header: Text(date.formattedDate())) {
                    ForEach(grouped[date] ?? []) { craving in
                        Text("Intensity: \(craving.intensity)")
                    }
                }
            }
        }
    }
}

struct DateListView_Previews: PreviewProvider {
    static var previews: some View {
        DateListView()
    }
}
