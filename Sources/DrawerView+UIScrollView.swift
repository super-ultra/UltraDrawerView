import UIKit

public extension DrawerView {
    
    /// It is compatible with any type of UIScrollView and UIScrollViewDelegate:
    /// (e.g. UITableViewDelegate, UICollectionViewDelegateFlowLayout and any other custom type).
    /// Do not overwrite scrollView.delegate, it will be used by ScrollDrawerViewContent.
    convenience init(scrollView: UIScrollView, delegate: UIScrollViewDelegate?, headerView: UIView) {
        self.init(content: ScrollDrawerViewContent(scrollView: scrollView, delegate: delegate), headerView: headerView)
    }
    
}

public extension SnappingView {
    
    /// It is compatible with any type of UIScrollView and UIScrollViewDelegate:
    /// (e.g. UITableViewDelegate, UICollectionViewDelegateFlowLayout and any other custom type).
    /// Do not overwrite scrollView.delegate, it will be used by ScrollDrawerViewContent.
    convenience init(scrollView: UIScrollView, delegate: UIScrollViewDelegate?, headerView: UIView) {
        self.init(content: ScrollDrawerViewContent(scrollView: scrollView, delegate: delegate), headerView: headerView)
    }
    
}
