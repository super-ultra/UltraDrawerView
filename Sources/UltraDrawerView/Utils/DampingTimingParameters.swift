import CoreGraphics
import Foundation

/// `amplitude` of the damping system towards zero.
internal protocol DampingTimingParameters {
    var duration: TimeInterval { get }
    func value(at time: TimeInterval) -> CGFloat
    func amplitude(at time: TimeInterval) -> CGFloat
}
