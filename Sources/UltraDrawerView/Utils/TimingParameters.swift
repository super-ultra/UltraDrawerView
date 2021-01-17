import CoreGraphics
import Foundation

internal protocol TimingParameters {
    var duration: TimeInterval { get }
    func value(at time: TimeInterval) -> CGFloat
}
