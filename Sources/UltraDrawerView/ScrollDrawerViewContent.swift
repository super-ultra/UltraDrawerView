import UIKit
internal import Combine

#if canImport(UltraDrawerViewObjCUtils)
    import UltraDrawerViewObjCUtils
#endif

/// It is compatible with any type of UIScrollView and UIScrollViewDelegate:
/// (e.g. UITableViewDelegate, UICollectionViewDelegateFlowLayout and any other custom type).
/// Do not overwrite scrollView.delegate, it will be used by ScrollDrawerViewContent.
@MainActor
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

@MainActor
private class ScrollDrawerViewContentImpl: NSObject {
    
    let scrollView: UIScrollView
    
    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        
        super.init()
        
        setupDelegate()
        
        self.scrollViewObservations = [
            scrollView.publisher(for: \.contentSize).sink { [weak self] newValue in
                guard let self else { return }
                self.listeners.forEach { $0.drawerViewContent(self, didChangeContentSize: newValue) }
            },
            scrollView.publisher(for: \.contentInset).sink { [weak self] newValue in
                guard let self else { return }
                self.listeners.forEach { $0.drawerViewContent(self, didChangeContentInset: newValue) }
            },
            scrollView.publisher(for: \.delegate).sink { [weak self] newValue in
                guard let self else { return }
                self.setupDelegate()
            }
        ]
    }
    
    // MARK: - Private
    
    private var listeners = WeakCollection<DrawerViewContentListener>()
    
    private var scrollViewObservations: Set<AnyCancellable> = []
    
    private let delegateProxy = SVPrivateScrollDelegateProxy()
    
    private func setupDelegate() {
        guard scrollView.delegate !== delegateProxy else { return }
        
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
        listeners.insert(listener)
    }
    
    func removeListener(_ listener: DrawerViewContentListener) {
        listeners.remove(listener)
    }
    
}

extension ScrollDrawerViewContentImpl: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listeners.forEach { $0.drawerViewContentDidScroll(self) }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        listeners.forEach { $0.drawerViewContentWillBeginDragging(self) }
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        listeners.forEach {
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
