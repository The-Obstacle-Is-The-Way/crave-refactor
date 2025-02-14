//
//  DateListView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct DateListView: View {
    @Environment(\.modelContext) private var modelContext // ✅ Get ModelContext from Environment
    @StateObject private var viewModel = DateListViewModel() // ✅ Initialize ViewModel with default init

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
                viewModel.setModelContext(modelContext!) // ✅ Set modelContext in onAppear (force unwrap is now safe here)
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


