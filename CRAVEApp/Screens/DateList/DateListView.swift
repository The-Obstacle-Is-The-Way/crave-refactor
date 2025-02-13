// DateListView.swift
import SwiftUI
import SwiftData

struct DateListView: View {
    @Query private var allCravings: [Craving]

    @Environment(\.modelContext) private var context
    @State private var viewModel = DateListViewModel()

    init() {
        let filter = #Predicate<Craving> { !$0.isDeleted }
        let descriptor = SortDescriptor(\Craving.timestamp, order: .reverse)
        _allCravings = Query(filter: filter, sort: [descriptor])
    }

    var body: some View {
        NavigationView {
            List {
                if viewModel.dateSections.isEmpty {
                    Text("No cravings logged yet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .accessibilityIdentifier("emptyStateText")
                } else {
                    ForEach(viewModel.dateSections, id: \.self) { date in
                        let cravingsForDate = viewModel.cravingsByDate[date] ?? []

                        NavigationLink {
                            CravingListView(
                                selectedDate: date,
                                cravings: cravingsForDate
                            )
                        } label: {
                            HStack {
                                Text(date, style: .date)
                                Spacer()
                                Text("\(cravingsForDate.count) items")
                                    .foregroundColor(.gray)
                            }
                            .accessibilityIdentifier("dateCell")
                        }
                        .accessibilityIdentifier("dateCellLink")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Craving Dates")
            .onAppear {
                viewModel.setData(allCravings)
            }
            .onChange(of: allCravings) { oldValue, newValue in
                viewModel.setData(newValue)
            }
            .accessibilityIdentifier("datesList")
        }
    }
}
