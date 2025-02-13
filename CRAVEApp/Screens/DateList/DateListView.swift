// DateListView.swift
// Displays a list of dates that have cravings. Tap to see cravings for that day.

import SwiftUI
import SwiftData

struct DateListView: View {
    @Query(sort: \Craving.timestamp, order: .reverse)
    private var allCravings: [Craving]

    @State private var viewModel = DateListViewModel()

    var body: some View {
        NavigationView {
            List {
                if viewModel.dateSections.isEmpty {
                    Text("No cravings logged yet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 100)
                } else {
                    ForEach(viewModel.dateSections, id: \.self) { date in
                        let cravingsForDate = viewModel.cravingsByDate[date] ?? []

                        NavigationLink {
                            CravingListView(selectedDate: date, cravings: cravingsForDate)
                        } label: {
                            Text(date, style: .date)
                        }
                        .accessibilityIdentifier("historyDateCell_\(date.timeIntervalSince1970)")
                    }
                }
            }
            .navigationTitle("Craving Dates")
            .onAppear {
                viewModel.groupCravings(allCravings)
            }
            // For iOS 17: zero-parameter onChange so we only re-group when the array changes
            .onChange(of: allCravings) {
                viewModel.groupCravings(allCravings)
            }
        }
    }
}
