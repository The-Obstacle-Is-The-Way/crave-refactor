import Foundation

public final class AnalyticsMapper {
    public init() {}

    public func mapToEntity(from metadata: AnalyticsMetadata) -> AnalyticsEntity {
        // Map AnalyticsMetadata to an AnalyticsEntity.
        return AnalyticsEntity(metadata: metadata)
    }
}

