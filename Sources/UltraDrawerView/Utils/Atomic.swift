import Foundation

internal final class Atomic<Value: Sendable>: @unchecked Sendable {

    init(_ initialValue: Value) {
        self._value = initialValue
    }
    
    var value: Value {
        _read {
            lock.lock()
            defer { lock.unlock() }
            yield _value
        } _modify {
            lock.lock()
            defer { lock.unlock() }
            yield &_value
        }
    }

    private var _value: Value
    private let lock = NSRecursiveLock()
}
