import CoreGraphics
import Foundation

public enum AnimationParameters {
    case spring(Spring)
}


public extension AnimationParameters {

    static func spring(mass: CGFloat, stiffness: CGFloat, dampingRatio: CGFloat) -> AnimationParameters {
        return .spring(Spring(mass: mass, stiffness: stiffness, dampingRatio: dampingRatio))
    }

}
