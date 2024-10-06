import UIKit

public protocol DrawerViewContent: AnyObject {
    /// View should be immutable
    @MainActor
    var view: UIView { get }
    
    @MainActor
    var contentOffset: CGPoint { get set }
    
    @MainActor
    var contentSize: CGSize { get }
    
    @MainActor
    var contentInset: UIEdgeInsets { get }
    
    @MainActor
    func addListener(_ listener: DrawerViewContentListener)
    
    @MainActor
    func removeListener(_ listener: DrawerViewContentListener)
}

public protocol DrawerViewContentListener: AnyObject {
    
    @MainActor
    func drawerViewContent(_ drawerViewContent: DrawerViewContent, didChangeContentSize contentSize: CGSize)
    
    @MainActor
    func drawerViewContent(_ drawerViewContent: DrawerViewContent, didChangeContentInset contentInset: UIEdgeInsets)
    
    @MainActor
    func drawerViewContentDidScroll(_ drawerViewContent: DrawerViewContent)
    
    @MainActor
    func drawerViewContentWillBeginDragging(_ drawerViewContent: DrawerViewContent)
    
    @MainActor
    func drawerViewContentWillEndDragging(
        _ drawerViewContent: DrawerViewContent,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    )
}
