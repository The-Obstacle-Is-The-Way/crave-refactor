//
//  DateListView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct DateListView: View {
    // ❌ Original (includes deleted cravings):
    // @Query(sort: \Craving.timestamp, order: .reverse)
    // private var allCravings: [Craving]
    
    // ✅ Updated: exclude soft-deleted cravings
    @Query(
        filter: #Predicate<Craving> { !$0.isDeleted },
        sort: \Craving.timestamp,
        order: .reverse
    )
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
                    }
                }
            }
            .navigationTitle("Craving Dates")
            .onAppear {
                viewModel.setData(allCravings)
            }
        }
    }
}
