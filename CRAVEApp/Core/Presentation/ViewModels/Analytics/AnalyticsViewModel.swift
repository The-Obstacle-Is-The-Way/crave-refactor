import Foundation
import SwiftData

@MainActor
public final class AnalyticsViewModel: ObservableObject {
    @Published public var basicStats: BasicAnalyticsResult?
    private let analyticsManager: AnalyticsManager

    public init(analyticsManager: AnalyticsManager) {
        self.analyticsManager = analyticsManager
    }

    public func loadAnalytics() async {
        do {
            self.basicStats = try await analyticsManager.getBasicStats()
        } catch {
            print("Error loading analytics: \(error)")
        }
    }
}

