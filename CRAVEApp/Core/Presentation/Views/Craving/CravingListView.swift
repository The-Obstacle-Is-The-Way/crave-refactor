// Core/Presentation/Views/Craving/CravingListView.swift

import SwiftUI

struct CravingListView: View {
    @StateObject private var viewModel: CravingListViewModel

    // Initialize via dependency injection
    init(viewModel: CravingListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.cravings) { craving in
            Text(craving.text)
        }
    }
}

