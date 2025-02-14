//
//  DateListView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct DateListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: DateListViewModel = DateListViewModel() // Initialize WITHOUT a context

    // ✅ Custom initializer to pass modelContext -- REMOVE THIS ENTIRE INITIALIZER
    //init() {
    //    _viewModel = StateObject(wrappedValue: DateListViewModel(modelContext: ModelContext())) // ⭐️ Provide a DUMMY ModelContext here
    //}

    var body: some View {
        NavigationView {
            List {
                if viewModel.cravings.isEmpty {
                    Text("No cravings logged yet.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.groupedCravings.keys.sorted(), id: \.self) { date in
                        Section(header: Text(date).font(.headline)) {
                            ForEach(viewModel.groupedCravings[date] ?? []) { craving in
                                VStack(alignment: .leading) {
                                    Text(craving.cravingText)
                                        .font(.headline)
                                    Text(craving.timestamp, style: .time)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Cravings by Date")
            .onAppear {
                viewModel.setModelContext(modelContext) // ✅ NOW set the REAL modelContext in onAppear
                viewModel.loadCravings() // ✅ THEN load data
            }
        }
    }
}


#Preview {
    DateListView()
}

