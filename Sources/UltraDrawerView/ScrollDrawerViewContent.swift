import UIKit

#if canImport(UltraDrawerViewObjCUtils)
    import UltraDrawerViewObjCUtils
#endif

/// It is compatible with any type of UIScrollView and UIScrollViewDelegate:
/// (e.g. UITableViewDelegate, UICollectionViewDelegateFlowLayout and any other custom type).
/// Do not overwrite scrollView.delegate, it will be used by ScrollDrawerViewContent.
open class ScrollDrawerViewContent: DrawerViewContent {

    open var scrollView: UIScrollView {
        return impl.scrollView
    }

    public init(scrollView: UIScrollView) {
        self.impl = Impl(scrollView: scrollView)
    }

    // MARK: - DrawerViewContent
    
    open var view: UIView {
        return impl.view
    }
    
    open var contentOffset: CGPoint {
        get {
            return impl.contentOffset
        }
        set {
            impl.contentOffset = newValue
        }
    }
    
    open var contentSize: CGSize {
        return impl.contentSize
    }
    
    open var contentInset: UIEdgeInsets {
        return impl.contentInset
    }
    
    open func addListener(_ listener: DrawerViewContentListener) {
        impl.addListener(listener)
    }
    
    open func removeListener(_ listener: DrawerViewContentListener) {
        impl.removeListener(listener)
    }
    
    // MARK: - Private
    
    private typealias Impl = ScrollDrawerViewContentImpl
    
    private let impl: Impl

}

// MARK: - Private Impl

private class ScrollDrawerViewContentImpl: NSObject {
    
    let scrollView: UIScrollView
    
    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        
        super.init()
        
        setupDelegate()
        
        self.scrollViewObservations = [
            scrollView.observe(\.contentSize, options: [.new, .old]) { [weak self] _, value in
                guard let self = self, let newValue = value.newValue, value.isChanged else { return }
                self.notifier.forEach { $0.drawerViewContent(self, didChangeContentSize: newValue) }
            },
            scrollView.observe(\.contentInset, options: [.new, .old]) { [weak self] _, value in
                guard let self = self, let newValue = value.newValue, value.isChanged else { return }
                self.notifier.forEach { $0.drawerViewContent(self, didChangeContentInset: newValue) }
            },
            scrollView.observe(\.delegate, options: [.new, .old]) { [weak self] _, value in
                guard let self = self, let old = value.newValue, old !== self.delegateProxy else { return }
                self.setupDelegate()
            }
        ]
    }
    
    deinit {
        // https://bugs.swift.org/browse/SR-5816
        scrollViewObservations = []
    }
    
    // MARK: - Private
    
    private let notifier = Notifier<DrawerViewContentListener>()
    
    private var scrollViewObservations: [NSKeyValueObservation] = []
    
    private let delegateProxy = SVPrivateScrollDelegateProxy()
    
    private func setupDelegate() {
        delegateProxy.mainDelegate = self
        delegateProxy.supplementaryDelegate = scrollView.delegate
        
        scrollView.delegate = delegateProxy
    }
    
}

extension ScrollDrawerViewContentImpl: DrawerViewContent {

    var view: UIView {
        return scrollView
    }
    
    var contentOffset: CGPoint {
        get {
            return scrollView.contentOffset
        }
        set {
            scrollView.contentOffset = newValue
        }
    }
    
    var contentSize: CGSize {
        return scrollView.contentSize
    }
    
    var contentInset: UIEdgeInsets {
        return scrollView.contentInset
    }
    
    func addListener(_ listener: DrawerViewContentListener) {
        notifier.subscribe(listener)
    }
    
    func removeListener(_ listener: DrawerViewContentListener) {
        notifier.unsubscribe(listener)
    }
    
}

extension ScrollDrawerViewContentImpl: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        notifier.forEach { $0.drawerViewContentDidScroll(self) }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        notifier.forEach { $0.drawerViewContentWillBeginDragging(self) }
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        notifier.forEach {
            $0.drawerViewContentWillEndDragging(self, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }

}

private extension CGFloat {
    
    func isEqual(to other: CGFloat, eps: CGFloat) -> Bool {
        return abs(self - other) < eps
    }
    
}

private extension CGSize {
    
    func isEqual(to other: CGSize, eps: CGFloat) -> Bool {
        return width.isEqual(to: other.width, eps: eps)
            && height.isEqual(to: other.height, eps: eps)
    }
    
}

private extension UIEdgeInsets {
    
    func isEqual(to other: UIEdgeInsets, eps: CGFloat) -> Bool {
        return top.isEqual(to: other.top, eps: eps)
            && left.isEqual(to: other.left, eps: eps)
            && bottom.isEqual(to: other.bottom, eps: eps)
            && right.isEqual(to: other.right, eps: eps)
    }
    
}

private extension NSKeyValueObservedChange where Value == CGSize {
    
    var isChanged: Bool {
        if let new = newValue, let old = oldValue {
            return !old.isEqual(to: new, eps: 0.0001)
        } else {
            return newValue != oldValue
        }
    }
    
}

private extension NSKeyValueObservedChange where Value == UIEdgeInsets {
    
    var isChanged: Bool {
        if let new = newValue, let old = oldValue {
            return !old.isEqual(to: new, eps: 0.0001)
        } else {
            return newValue != oldValue
        }
    }
    
}
