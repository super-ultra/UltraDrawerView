import QuartzCore

internal final class TimerAnimation {

    enum TargetState {
        case `continue`
        case finish
    }

    typealias Animations = (_ time: TimeInterval) -> TargetState
    typealias Completion = (_ finished: Bool) -> Void
    
    private(set) var running: Bool = true
    
    init(animations: @escaping Animations, completion: Completion? = nil) {
        self.animations = animations
        self.completion = completion

        self.firstFrameTimestamp = CACurrentMediaTime()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(handleFrame(_:)))
        displayLink.add(to: .main, forMode: RunLoop.Mode.common)
        self.displayLink = displayLink
    }
    
    deinit {
        invalidate()
    }

    func invalidate(withColmpletion: Bool = true) {
        guard running else { return }
        running = false
        if withColmpletion {
            completion?(false)
        }
        displayLink?.invalidate()
    }
    
    // MARK: - Private

    private let animations: Animations
    private let completion: Completion?
    private weak var displayLink: CADisplayLink?

    private let firstFrameTimestamp: CFTimeInterval

    @objc private func handleFrame(_ displayLink: CADisplayLink) {
        guard running else { return }
        let elapsed = CACurrentMediaTime() - firstFrameTimestamp

        let targetState = animations(elapsed)
        switch targetState {
        case .continue:
            break
        case .finish:
            running = false
            completion?(true)
            displayLink.invalidate()
        }
    }
}
