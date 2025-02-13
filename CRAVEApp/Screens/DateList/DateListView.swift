//
//  DateListView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct DateListView: View {
    @Query(
        sort: [SortDescriptor(\Craving.timestamp, order: .reverse)]
    )
    private var allCravings: [Craving]  // ✅ Removed isDeleted filter to ensure all cravings show

    @Environment(\.modelContext) private var context
    @State private var viewModel = DateListViewModel()

    var body: some View {
        NavigationView {
            List {
                if viewModel.dateSections.isEmpty {
                    Text("No cravings logged yet.")
                        .accessibilityIdentifier("emptyStateText")
                } else {
                    ForEach(viewModel.dateSections, id: \.self) { date in
                        let cravingsForDate = viewModel.cravingsByDate[date] ?? []

                        NavigationLink {
                            CravingListView(selectedDate: date, cravings: cravingsForDate)
                        } label: {
                            HStack {
                                Text(date, style: .date)
                                Spacer()
                                Text("\(cravingsForDate.count) items")
                                    .foregroundColor(.gray)
                            }
                        }
                        .accessibilityIdentifier("historyDateCell_\(date.timeIntervalSince1970)")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Craving Dates")
            .onAppear {
                forceUIRefresh()
                printCravingDebugLogs()
                viewModel.setData(allCravings)
            }
            .onChange(of: allCravings) { _, newValue in
                forceUIRefresh()
                printCravingDebugLogs()
                viewModel.setData(newValue)
            }
            .accessibilityIdentifier("datesList")
        }
    }

    /// 🚨 FORCE SWIFTUI TO REFRESH THE VIEW
    private func forceUIRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                viewModel.setData(allCravings)
            }
        }
    }

    /// 🚨 PRINT DEBUG LOGS TO CONFIRM DATA
    private func printCravingDebugLogs() {
        print("🟡 `DateListView` appeared. Found cravings: \(allCravings.count)")
        allCravings.forEach { print("📝 Craving: \($0.text) | Timestamp: \($0.timestamp) | Deleted: \($0.isDeleted)") }
    }
}
