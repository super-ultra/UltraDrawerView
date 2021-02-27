import CoreGraphics


internal final class SnappingViewSpringAnimation: SnappingViewAnimation {
    
    init(
        initialOrigin: CGFloat,
        targetOrigin: CGFloat,
        initialVelocity: CGFloat,
        parameters: AnimationParameters,
        onUpdate: @escaping (CGFloat) -> Void,
        completion: @escaping (Bool) -> Void
    ) {
        self.currentOrigin = initialOrigin
        self.currentVelocity = initialVelocity
        self.targetOrigin = targetOrigin
        self.parameters = parameters
        self.threshold = 0.5
        self.onUpdate = onUpdate
        self.completion = completion
        
        updateAnimation()
    }
    
    func invalidate() {
        animation?.invalidate()
    }
    
    // MARK: - SnappingViewAnimation
    
    var targetOrigin: CGFloat {
        didSet {
            updateAnimation()
        }
    }
    
    var isDone: Bool {
        return animation?.running ?? false
    }
    
    // MARK: - Private
    
    private var currentOrigin: CGFloat
    private var currentVelocity: CGFloat
    private let parameters: AnimationParameters
    private let threshold: CGFloat
    private let onUpdate: (CGFloat) -> Void
    private let completion: (Bool) -> Void
    private var animation: TimerAnimation?
    
    private func updateAnimation() {
        guard !isDone else { return }
        
        animation?.invalidate(withColmpletion: false)

        let to = targetOrigin
        let timingParameters = makeTimingParameters()
        
        animation = TimerAnimation(
            animations: { [weak self, timingParameters, threshold] time in
                guard let self = self else {
                    return .finish
                }

                self.currentOrigin = to + timingParameters.value(at: time)
                self.onUpdate(self.currentOrigin)

                return timingParameters.amplitude(at: time) < threshold ? .finish : .continue
            },
            completion: { [onUpdate, completion] finished in
                if finished {
                    onUpdate(to)
                }
                completion(finished)
            }
        )
    }

    private func makeTimingParameters() -> DampingTimingParameters {
        let from = currentOrigin
        let to = targetOrigin

        switch parameters {
        case let .spring(spring):
            return SpringTimingParameters(
                spring: spring,
                displacement: from - to,
                initialVelocity: currentVelocity,
                threshold: threshold
            )
        }
    }
}
