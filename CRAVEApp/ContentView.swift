//
//  ContentView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel: CravingListViewModel
    
    // Removed 'public' to match CravingManager's access level.
    init(cravingManager: CravingManager) {
        _viewModel = StateObject(wrappedValue: CravingListViewModel(cravingManager: cravingManager))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.cravings) { craving in
                    Text("Craving at \(craving.timestamp, formatter: Self.dateFormatter)")
                }
            }
            .navigationTitle("CRAVE")
            .onAppear {
                viewModel.loadCravings()
            }
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

// A wrapper view that injects the ModelContext from the environment into ContentView.
struct ContentViewWrapper: View {
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        ContentView(cravingManager: CravingManager(context: modelContext))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        do {
            let container = try ModelContainer(for: CravingModel.self)
            return ContentViewWrapper()
                .environment(\.modelContext, container.mainContext)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
