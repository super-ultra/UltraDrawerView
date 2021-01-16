import Foundation
import CoreGraphics

func rubberBandClamp(_ x: CGFloat, coeff: CGFloat = 0.55, dim: CGFloat) -> CGFloat {
    return (1.0 - (1.0 / ((x * coeff / dim) + 1.0))) * dim
}

func rubberBandClamp(_ x: CGFloat, coeff: CGFloat = 0.55, limits: ClosedRange<CGFloat>) -> CGFloat {
    let clampedX = x.clamped(to: limits)
    let diff = abs(x - clampedX)
    let sign: CGFloat = clampedX > x ? -1 : 1
    let dim = limits.upperBound - limits.lowerBound
    return clampedX + sign * rubberBandClamp(diff, coeff: coeff, dim: dim)
}
