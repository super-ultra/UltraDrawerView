import Foundation

internal struct WeakCollection<T> {

    init() {
        elems = []
    }

    func forEach(_ block: (T) -> Void) {
        for elem in elems {
            if let obj = elem.object as? T {
                block(obj)
            }
        }
    }
    
    mutating func insert(_ elem: T) {
        removeNilElems()
        if index(of: elem) == nil {
            elems.append(Box(elem as AnyObject))
        }
    }
    
    mutating func remove(_ elem: T) {
        removeNilElems()
        if let index = index(of: elem) {
            elems.remove(at: index)
        }
    }

    mutating func isEmpty() -> Bool {
        removeNilElems()
        return elems.isEmpty
    }

    // MARK: - Private
    
    private class Box {
        weak var object: AnyObject?
        
        init(_ object: AnyObject) {
            self.object = object
        }
    }

    private var elems: ContiguousArray<Box>
    
    private mutating func removeNilElems() {
        elems = elems.filter { $0.object != nil }
    }
    
    private func index(of elem: T) -> Int? {
        return elems.firstIndex(where: { $0.object === elem as AnyObject })
    }
    
}
