import SwiftUI

public struct CravingListView: View {
    @ObservedObject public var viewModel: CravingListViewModel

    public init(viewModel: CravingListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List(viewModel.cravings) { craving in
            Text(craving.text)
        }
        .task {
            await viewModel.loadCravings()
        }
    }
}

