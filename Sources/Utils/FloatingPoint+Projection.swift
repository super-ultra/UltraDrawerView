import Foundation

internal extension FloatingPoint {

    static func project(initialVelocity: Self, decelerationRate: Self) -> Self {
        if decelerationRate >= 1 {
            assert(false)
            return initialVelocity
        }
        
        return initialVelocity * decelerationRate / (1 - decelerationRate)
    }
    
    func project(initialVelocity: Self, decelerationRate: Self) -> Self {
        return self + Self.project(initialVelocity: initialVelocity, decelerationRate: decelerationRate)
    }

}
