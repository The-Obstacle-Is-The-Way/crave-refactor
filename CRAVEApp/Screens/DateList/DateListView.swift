//
//  DateListView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct DateListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cravings: [Craving]

    // ✅ State variable to trigger a UI refresh
    @State private var forceRefresh = false

    var body: some View {
        List {
            ForEach(cravings.filter { !$0.isDeleted }) { craving in
                Text(craving.text)
                    .accessibilityIdentifier("historyDateCell")
            }
        }
        .id(forceRefresh) // ✅ Forces SwiftUI to refresh
        .onAppear {
            refreshUI()
        }
    }

    /// 🚀 Forces SwiftUI to refresh `@Query`
    private func refreshUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.forceRefresh.toggle()
        }
    }
}
