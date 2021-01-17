import Foundation

internal extension FloatingPoint {

    func isLess(than other: Self, eps: Self) -> Bool {
        return self < other - eps
    }
    
    func isGreater(than other: Self, eps: Self) -> Bool {
        return self > other + eps
    }
    
    func isEqual(to other: Self, eps: Self) -> Bool {
        return abs(self - other) < eps
    }

}
