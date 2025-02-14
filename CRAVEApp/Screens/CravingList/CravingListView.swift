//
//  CravingListView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct CravingListView: View {
    @StateObject private var viewModel = CravingListViewModel() // ✅ Ensures proper observation

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.cravings) { craving in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(craving.cravingText)
                                .font(.headline)
                            Text(craving.timestamp, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {
                            withAnimation {
                                viewModel.archiveCraving(craving) // ✅ Soft delete instead of remove
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .accessibilityLabel("Delete craving")
                    }
                }
            }
            .navigationTitle("Cravings")
        }
    }
}

// ✅ Preview with sample data
struct CravingListView_Previews: PreviewProvider {
    static var previews: some View {
        CravingListView()
            .modelContainer(for: CravingModel.self, inMemory: true) // ✅ Ensure ModelContainer is available
    }
}
