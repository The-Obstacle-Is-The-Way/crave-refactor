//ContentView.swift

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = CravingListViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.cravings) { craving in
                    HStack {
                        Text(craving.cravingText)
                            .font(.headline)
                        Spacer()
                        Text(craving.timestamp, style: .date)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete { offsets in
                    viewModel.deleteCravings(at: offsets)
                }
            }
            .navigationTitle("Cravings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.loadCravings()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadCravings()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: CravingModel.self, inMemory: true)
    }
}
