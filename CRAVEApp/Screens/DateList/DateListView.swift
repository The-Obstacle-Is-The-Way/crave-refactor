// DateListView.swift

import SwiftUI
import SwiftData

struct DateListView: View {
    @Query(
        sort: [SortDescriptor(\Craving.timestamp, order: .reverse)]
    )
    private var allCravings: [Craving]

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
                viewModel.setData(allCravings)
            }
            .onChange(of: allCravings) { _, newValue in
                viewModel.setData(newValue)
            }
            .accessibilityIdentifier("datesList")
        }
    }
}
