//
//  DateListView.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25
//

import SwiftUI
import SwiftData

struct DateListView: View {
    // Explicitly specify Craving as the root type and use .reverse instead of .descending
    @Query(sort: \Craving.timestamp, order: .reverse)
    private var allCravings: [Craving]

    @State private var viewModel = DateListViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.dateSections, id: \.self) { date in
                    let cravingsForDate = viewModel.cravingsByDate[date] ?? []
                    NavigationLink {
                        CravingListView(selectedDate: date, cravings: cravingsForDate)
                    } label: {
                        Text(date, style: .date)
                    }
                }
            }
            .navigationTitle("Craving Dates")
            .onAppear {
                viewModel.groupCravings(allCravings)
            }
        }
    }
}
