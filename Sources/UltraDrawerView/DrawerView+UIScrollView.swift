import UIKit

public extension DrawerView {
    
    /// It is compatible with any type of `UIScrollView`.
    /// `scrollView.delegate` will be used by `ScrollDrawerViewContent`.
    convenience init(scrollView: UIScrollView, headerView: UIView) {
        self.init(content: ScrollDrawerViewContent(scrollView: scrollView), headerView: headerView)
    }
    
}

public extension SnappingView {
    
    /// It is compatible with any type of `UIScrollView`.
    /// `scrollView.delegate` will be used by `ScrollDrawerViewContent`.
    convenience init(scrollView: UIScrollView, headerView: UIView) {
        self.init(content: ScrollDrawerViewContent(scrollView: scrollView), headerView: headerView)
    }
    
}
