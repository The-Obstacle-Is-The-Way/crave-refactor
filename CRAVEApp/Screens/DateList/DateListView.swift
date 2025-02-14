
//
//  DateListView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct DateListView: View {
    @Environment(\.modelContext) private var modelContext // ✅ Get ModelContext from Environment
    @StateObject private var viewModel: DateListViewModel // ✅ Use StateObject, but DECLARE it, don't initialize here

    // ✅ Custom initializer to pass modelContext
    init() {
        _viewModel = StateObject(wrappedValue: DateListViewModel(modelContext: ModelContext())) // ⭐️ Provide a DUMMY ModelContext here
    }

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
                viewModel.setModelContext(modelContext!) // ✅ NOW set the REAL modelContext in onAppear
                viewModel.loadCravings() // ✅ THEN load data
            }
        }
    }
}

// ✅ Preview with sample data
struct DateListView_Previews: PreviewProvider {
    static var previews: some View {
        DateListView()
            .modelContainer(for: CravingModel.self, inMemory: true)
    }
}

