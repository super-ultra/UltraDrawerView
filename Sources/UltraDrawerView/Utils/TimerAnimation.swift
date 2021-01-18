import QuartzCore

internal final class TimerAnimation {

    typealias Animations = (_ progress: Double, _ time: TimeInterval) -> Void
    typealias Completion = (_ finished: Bool) -> Void
    
    private(set) var running: Bool = true

    @available(iOS 10.0, *)
    var preferredFramesPerSecond: Int {
        get {
            return displayLink?.preferredFramesPerSecond ?? 0
        }
        set {
            displayLink?.preferredFramesPerSecond = newValue
        }
    }
    
    init(duration: TimeInterval, animations: @escaping Animations, completion: Completion? = nil) {
        self.duration = duration
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

    private let duration: TimeInterval
    private let animations: Animations
    private let completion: Completion?
    private weak var displayLink: CADisplayLink?

    private let firstFrameTimestamp: CFTimeInterval

    @objc private func handleFrame(_ displayLink: CADisplayLink) {
        guard running else { return }
        let elapsed = CACurrentMediaTime() - firstFrameTimestamp
        if elapsed >= duration {
            animations(1, duration)
            running = false
            completion?(true)
            displayLink.invalidate()
        } else {
            animations(elapsed / duration, elapsed)
        }
    }
}
