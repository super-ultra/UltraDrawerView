import Foundation

internal struct WeakCollection<T>: Sendable {

    init() {
        self.elems = Atomic([])
    }

    func forEach(_ block: (T) -> Void) {
        for elem in elems.value {
            if let obj = elem.object as? T {
                block(obj)
            }
        }
    }
    
    mutating func insert(_ elem: T) {
        removeNilElems()
        if index(of: elem) == nil {
            elems.value.append(Box(elem as AnyObject))
        }
    }
    
    mutating func remove(_ elem: T) {
        removeNilElems()
        if let index = index(of: elem) {
            elems.value.remove(at: index)
        }
    }

    mutating func isEmpty() -> Bool {
        removeNilElems()
        return elems.value.isEmpty
    }

    // MARK: - Private
    
    private final class Box: @unchecked Sendable {
        weak var object: AnyObject?
        
        init(_ object: AnyObject) {
            self.object = object
        }
    }

    private var elems: Atomic<Array<Box>>
    
    private mutating func removeNilElems() {
        elems.value = elems.value.filter { $0.object != nil }
    }
    
    private func index(of elem: T) -> Int? {
        return elems.value.firstIndex(where: { $0.object === elem as AnyObject })
    }
    
}
