//
//  ContentView.swift
//  CRAVE
//

import SwiftUI

public struct ContentView: View {
    @StateObject private var viewModel = CravingListViewModel(cravingManager: CravingManager())
    
    public var body: some View {
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

struct ContentView_Previews: PreviewProvider {
    public static var previews: some View {
        ContentView()
    }
}
