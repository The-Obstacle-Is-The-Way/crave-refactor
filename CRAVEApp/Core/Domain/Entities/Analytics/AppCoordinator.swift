import SwiftUI

public class AppCoordinator: ObservableObject {
    public init() {}
    
    public func start() -> some View {
        CRAVETabView()
    }
}

