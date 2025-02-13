// CravingListView.swift

import SwiftUI
import SwiftData

struct CravingListView: View {
    @Query(sort: \CravingModel.timestamp, animation: .default)
    private var cravings: [CravingModel]
    
    var body: some View {
        List(cravings, id: \.self) { craving in
            VStack(alignment: .leading) {
                Text("Intensity: \(craving.intensity)")
                Text("Logged on: \(craving.timestamp.formattedDate())")
            }
        }
    }
}

struct CravingListView_Previews: PreviewProvider {
    static var previews: some View {
        CravingListView()
    }
}
