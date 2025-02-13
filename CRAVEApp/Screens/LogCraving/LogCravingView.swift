//
//  LogCravingView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct LogCravingView: View {
    @StateObject var viewModel: LogCravingViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Log Your Craving")
                .font(.headline)
            
            TextEditor(text: $viewModel.note)
                .frame(height: 150)
                .border(Color.gray)
            
            Stepper("Intensity: \(viewModel.intensity)", value: $viewModel.intensity, in: 1...10)
            
            Button("Save") {
                viewModel.saveCraving()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct LogCravingView_Previews: PreviewProvider {
    static var previews: some View {
        do {
            // Create a ModelContainer for CravingModel as per SwiftData documentation
            let container = try ModelContainer(for: CravingModel.self)
            let dummyContext = container.mainContext
            let dummyCravingManager = CravingManager(context: dummyContext)
            let viewModel = LogCravingViewModel(cravingManager: dummyCravingManager)
            return LogCravingView(viewModel: viewModel)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
