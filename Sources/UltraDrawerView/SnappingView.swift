import UIKit


/// SnappingViewAnimation allows to control targetOrigin during animation
public protocol SnappingViewAnimation: AnyObject {
    var targetOrigin: CGFloat { get set }
    var isDone: Bool { get }
}

public protocol SnappingViewListener: AnyObject {
    func snappingView(_ snappingView: SnappingView, willBeginUpdatingOrigin origin: CGFloat, source: DrawerOriginChangeSource)
    func snappingView(_ snappingView: SnappingView, didUpdateOrigin origin: CGFloat, source: DrawerOriginChangeSource)
    func snappingView(_ snappingView: SnappingView, didEndUpdatingOrigin origin: CGFloat, source: DrawerOriginChangeSource)
    func snappingView(_ snappingView: SnappingView, willBeginAnimation animation: SnappingViewAnimation, source: DrawerOriginChangeSource)
}

open class SnappingView: UIView {

    public typealias Content = DrawerViewContent
    
    public let content: Content
    
    public let headerView: UIView
    
    /// The view containing the header view and the content view.
    /// It represents the visible and tappable area of the SnappingView.
    /// E.g. it can be used for a shadow or mask.
    public let containerView: UIView

    open private(set) var origin: CGFloat {
        didSet {
            containerOriginConstraint?.constant = origin
        }
    }
    
    open var anchors: [CGFloat]
    
    open var isDragging: Bool {
        if case .dragging = headerState {
            return true
        } else if case .dragging = contentState {
            return true
        } else {
            return false
        }
    }
    
    /// A Boolean value that controls whether the scroll view bounces past the edge of content and back again
    open var bounces: Bool = true

    /// Animation parameters for the transitions between anchors
    open var animationParameters: AnimationParameters = .spring(.default)
    
    public init(content: Content, headerView: UIView) {
        self.content = content
        self.headerView = headerView
        self.containerView = UIView()
        self.origin = 0
        self.anchors = []

        super.init(frame: .zero)
        
        setupViews()
    }
    
    open func scroll(toOrigin origin: CGFloat, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        notifyWillBeginUpdatingOrigin(with: .program)
        moveOrigin(to: origin, source: .program, animated: animated, completion: completion)
    }
    
    open func addListener(_ listener: SnappingViewListener) {
        notifier.subscribe(listener)
    }
    
    open func removeListener(_ listener: SnappingViewListener) {
        notifier.unsubscribe(listener)
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let visibleRect = CGRect(x: 0.0, y: origin, width: bounds.width, height: bounds.height - origin)
        return visibleRect.contains(point)
    }
    
    // MARK: - Private
    
    private enum Static {
        static let originEps: CGFloat = 1 / UIScreen.main.scale
    }
    
    private let notifier = Notifier<SnappingViewListener>()
    
    private var containerOriginConstraint: NSLayoutConstraint?
    
    private func setupViews() {
        addSubview(containerView)
    
        containerView.addSubview(content.view)
        content.view.clipsToBounds = false
        content.addListener(self)
        
        containerView.addSubview(headerView)
        containerView.addGestureRecognizer(headerPanRecognizer)
        headerPanRecognizer.addTarget(self, action: #selector(handleHeaderPanRecognizer))
        
        setupLayout()
    }
    
    private func setupLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.set([.left, .right], equalTo: self)
        containerView.set(.bottom, equalTo: self, priority: .fittingSizeLevel)
        containerOriginConstraint = containerView.set(.top, equalTo: self, constant: origin)
    
        content.view.translatesAutoresizingMaskIntoConstraints = false
        content.view.set([.left, .right], equalTo: containerView)
        content.view.set(.bottom, equalTo: containerView)
        content.view.set(.top, equalTo: headerView, attribute: .bottom)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.set([.left, .right, .top], equalTo: containerView)
        if headerView.constraints.isEmpty, !type(of: headerView).requiresConstraintBasedLayout {
            headerView.set(.height, equalTo: headerView.frame.height)
        }
    }
    
    private func setOrigin(_ origin: CGFloat, source: DrawerOriginChangeSource) {
        self.origin = origin
        notifier.forEach { $0.snappingView(self, didUpdateOrigin: origin, source: source) }
    }
    
    private func notifyWillBeginUpdatingOrigin(with source: DrawerOriginChangeSource) {
        notifier.forEach { $0.snappingView(self, willBeginUpdatingOrigin: origin, source: source) }
    }
    
    private func notifyDidEndUpdatingOrigin(with source: DrawerOriginChangeSource) {
        notifier.forEach { $0.snappingView(self, didEndUpdatingOrigin: origin, source: source) }
    }
    
    // MARK: - Private: Content
    
    private enum ContentState: Equatable {
        case normal
        case dragging(lastContentOffset: CGPoint)
    }
    
    private var contentState: ContentState = .normal
    
    private var targetContentBottomPosition: CGFloat {
        if let anchorLimits = anchorLimits {
            return bounds.height - anchorLimits.lowerBound
        } else {
            return bounds.height
        }
    }
    
    // MARK: - Private: Header
    
    private enum HeaderState: Equatable {
        case normal
        case dragging(initialOrigin: CGFloat)
    }
    
    private var headerState: HeaderState = .normal
    
    private let headerPanRecognizer = UIPanGestureRecognizer()
    
    private var anchorLimits: ClosedRange<CGFloat>? {
        if let min = anchors.min(), let max = anchors.max() {
            return min ... max
        } else {
            return nil
        }
    }
    
    private var isHeaderInteractionEnabled: Bool {
        return anchors.count > 1 || origin != anchors.first
    }
    
    @objc private func handleHeaderPanRecognizer(_ sender: UIPanGestureRecognizer) {
        if !isHeaderInteractionEnabled {
            return
        }
    
        switch sender.state {
        case .began:
            stopOriginAnimation()
            headerState = .dragging(initialOrigin: origin)
            notifyWillBeginUpdatingOrigin(with: .headerInteraction)
        
        case .changed:
            let translation = sender.translation(in: headerView)
        
            if case let .dragging(initialOrigin) = headerState {
                let newOrigin = clampTargetHeaderOrigin(initialOrigin + translation.y)
                setOrigin(newOrigin, source: .headerInteraction)
            }
        
        case .ended:
            headerState = .normal
            
            let velocity = sender.velocity(in: headerView).y / 1000
            
            moveOriginToTheNearestAnchor(withVelocity: velocity, source: .headerInteraction)
            
        case .cancelled, .failed:
            headerState = .normal
            notifyDidEndUpdatingOrigin(with: .headerInteraction)
        
        case .possible:
            break
        @unknown default:
            fatalError()
        }
    }
    
    private func clampTargetHeaderOrigin(_ target: CGFloat) -> CGFloat {
        guard let limits = anchorLimits else { return target }
        
        if !bounces {
            return target.clamped(to: limits)
        }
        
        if target < limits.lowerBound {
            let diff = limits.lowerBound - target
            let dim = abs(limits.lowerBound)
            return limits.lowerBound - rubberBandClamp(diff, dim: dim)
        } else if target > limits.upperBound {
            let diff = target - limits.upperBound
            let dim = abs(bounds.height - limits.upperBound)
            return limits.upperBound + rubberBandClamp(diff, dim: dim)
        } else {
            return target
        }
    }
    
    // MARK: - Private: Anchors

    private var originAnimation: SnappingViewSpringAnimation?
    
    private func selectNextAnchor(to anchor: CGFloat, velocity: CGFloat) -> CGFloat {
        if velocity == 0 || anchors.isEmpty {
            return anchor
        }
        
        let sortedAnchors = anchors.sorted()
        
        if let anchorIndex = sortedAnchors.firstIndex(of: anchor) {
            let nextIndex = velocity > 0 ? anchorIndex + 1 : anchorIndex - 1
            let clampedIndex = nextIndex.clamped(to: 0 ... anchors.count - 1)
            return sortedAnchors[clampedIndex]
        }
        
        return anchor
    }
    
    private func moveOriginToTheNearestAnchor(
        withVelocity velocity: CGFloat,
        source: DrawerOriginChangeSource,
        completion: ((Bool) -> Void)? = nil
    ) {
        let decelerationRate = UIScrollView.DecelerationRate.fast.rawValue
        let projection = origin.project(initialVelocity: velocity, decelerationRate: decelerationRate)
        
        guard let projectionAnchor = anchors.nearestElement(to: projection) else { return }
        
        let targetAnchor: CGFloat
    
        if (projectionAnchor - origin) * velocity < 0 { // if velocity is too low to change the current anchor
            // select the next anchor anyway
            targetAnchor = selectNextAnchor(to: projectionAnchor, velocity: velocity)
        } else {
            targetAnchor = projectionAnchor
        }
        
        if !origin.isEqual(to: targetAnchor, eps: Static.originEps) {
            moveOrigin(to: targetAnchor, source: source, animated: true, velocity: velocity)
        }
    }
    
    private func moveOrigin(
        to newOriginY: CGFloat,
        source: DrawerOriginChangeSource,
        animated: Bool,
        velocity: CGFloat? = nil,
        completion: ((Bool) -> Void)? = nil
    ) {
        if !animated {
            setOrigin(newOriginY, source: source)
            notifyDidEndUpdatingOrigin(with: source)
            completion?(true)
            return
        }
        
        let originAnimation = SnappingViewSpringAnimation(
            initialOrigin: origin,
            targetOrigin: newOriginY,
            initialVelocity: velocity ?? 0,
            parameters: animationParameters,
            onUpdate: { [weak self] value in
                self?.setOrigin(value, source: source)
            },
            completion: { [weak self] finished in
                self?.notifyDidEndUpdatingOrigin(with: source)
                completion?(finished)
            }
        )
        
        self.originAnimation = originAnimation
    
        notifier.forEach { $0.snappingView(self, willBeginAnimation: originAnimation, source: source) }
    }
    
    private func stopOriginAnimation() {
        originAnimation?.invalidate()
        originAnimation = nil
    }
    
}

extension SnappingView: DrawerViewContentListener {

    public func drawerViewContent(_ drawerViewContent: DrawerViewContent, didChangeContentSize contentSize: CGSize) {}
    
    public func drawerViewContent(_ drawerViewContent: DrawerViewContent, didChangeContentInset contentInset: UIEdgeInsets) {}
    
    public func drawerViewContentDidScroll(_ drawerViewContent: DrawerViewContent) {
        guard case let .dragging(lastContentOffset) = contentState else { return }
        
        defer {
            contentState = .dragging(lastContentOffset: drawerViewContent.contentOffset)
        }
        
        guard let limits = anchorLimits, isHeaderInteractionEnabled else { return }
        
        let diff = lastContentOffset.y - drawerViewContent.contentOffset.y
    
        if (diff < 0
            && drawerViewContent.contentOffset.y > -drawerViewContent.contentInset.top
            && origin.isGreater(than: limits.lowerBound, eps: Static.originEps))
            || (diff > 0
                && drawerViewContent.contentOffset.y < -drawerViewContent.contentInset.top
                && origin.isLess(than: limits.upperBound, eps: Static.originEps))
        {
            // Drop contentOffset changing
            drawerViewContent.removeListener(self)
            if diff > 0 {
                drawerViewContent.contentOffset.y = -drawerViewContent.contentInset.top
            } else {
                drawerViewContent.contentOffset.y += diff
            }
            drawerViewContent.addListener(self)
            
            let newOrigin = (origin + diff).clamped(to: limits)
            
            setOrigin(newOrigin, source: .contentInteraction)
        }
    }
    
    public func drawerViewContentWillBeginDragging(_ drawerViewContent: DrawerViewContent) {
        contentState = .dragging(lastContentOffset: drawerViewContent.contentOffset)
        
        stopOriginAnimation()
        notifyWillBeginUpdatingOrigin(with: .contentInteraction)
    }
    
    public func drawerViewContentWillEndDragging(
        _ drawerViewContent: DrawerViewContent,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        contentState = .normal
    
        guard let limits = anchorLimits, limits.contains(origin, eps: Static.originEps) else {
            notifyDidEndUpdatingOrigin(with: .contentInteraction)
            return
        }
        
        // Stop scrolling
        targetContentOffset.pointee = drawerViewContent.contentOffset
        
        moveOriginToTheNearestAnchor(withVelocity: -velocity.y, source: .contentInteraction)
    }
    
}


private extension ClosedRange where Bound: FloatingPoint {
    
    func contains(_ element: Bound, eps: Bound) -> Bool {
        return element.isGreater(than: lowerBound, eps: eps) && element.isLess(than: upperBound, eps: eps)
    }
    
}
