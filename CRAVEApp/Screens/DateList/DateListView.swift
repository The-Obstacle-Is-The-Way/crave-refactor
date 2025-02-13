//
//  DateListView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct DateListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cravings: [Craving]
    
    @State private var allCravings: [Craving] = []
    @State private var forceRefresh = false  // ✅ Force UI refresh

    var body: some View {
        List {
            ForEach(allCravings.filter { !$0.isArchived }) { craving in
                Text(craving.text)
                    .accessibilityIdentifier("historyDateCell_\(craving.id.uuidString)") // ✅ Ensure correct identifier
            }
        }
        .id(forceRefresh) // ✅ Forces SwiftUI to refresh
        .onAppear {
            refreshCravings()
        }
    }

    /// 🚀 Manually re-fetch cravings and update UI
    private func refreshCravings() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.allCravings = try! modelContext.fetch(FetchDescriptor<Craving>())
            self.forceRefresh.toggle()
        }
    }
}
