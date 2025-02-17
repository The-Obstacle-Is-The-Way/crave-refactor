import Foundation

public final class CravingMapper {
    public init() {}

    public func mapToEntity(from dto: CravingDTO) -> CravingEntity {
        return CravingEntity(text: dto.text, timestamp: dto.timestamp)
    }
}

