//
//  LogCravingView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

public struct LogCravingView: View {
    @StateObject public var viewModel: LogCravingViewModel = LogCravingViewModel()
    
    public init() { }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextEditor(text: $viewModel.typedText)
                    .padding()
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                Button(action: {
                    viewModel.logCraving()
                }) {
                    Text("Submit")
                        .font(.body)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                if let loggedCraving = viewModel.currentCraving {
                    Text("Last logged craving: \(loggedCraving.notes ?? "")")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .navigationTitle("Log a Craving")
        }
    }
}

struct LogCravingView_Previews: PreviewProvider {
    public static var previews: some View {
        LogCravingView()
    }
}
