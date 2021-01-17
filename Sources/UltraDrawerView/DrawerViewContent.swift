import UIKit

public protocol DrawerViewContent: AnyObject {
    /// View should be immutable
    var view: UIView { get }
    var contentOffset: CGPoint { get set }
    var contentSize: CGSize { get }
    var contentInset: UIEdgeInsets { get }
    func addListener(_ listener: DrawerViewContentListener)
    func removeListener(_ listener: DrawerViewContentListener)
}

public protocol DrawerViewContentListener: AnyObject {
    func drawerViewContent(_ drawerViewContent: DrawerViewContent, didChangeContentSize contentSize: CGSize)
    
    func drawerViewContent(_ drawerViewContent: DrawerViewContent, didChangeContentInset contentInset: UIEdgeInsets)
    
    func drawerViewContentDidScroll(_ drawerViewContent: DrawerViewContent)
    
    func drawerViewContentWillBeginDragging(_ drawerViewContent: DrawerViewContent)
    
    func drawerViewContentWillEndDragging(
        _ drawerViewContent: DrawerViewContent,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    )
}
