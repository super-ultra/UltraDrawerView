import Foundation

internal extension Collection where Element: Comparable & SignedNumeric {
    
    func nearestElement(to value: Element) -> Element? {
        return self.min(by: { abs($0 - value) < abs($1 - value) })
    }
    
}
