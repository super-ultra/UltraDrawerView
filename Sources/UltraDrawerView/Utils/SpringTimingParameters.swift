import CoreGraphics
import Foundation

/// https://en.wikipedia.org/wiki/Harmonic_oscillator
///
/// System's equation of motion:
///
/// 0 < dampingRatio < 1:
/// x(t) = exp(-beta * t) * (c1 * sin(w' * t) + c2 * cos(w' * t))
/// c1 = x0
/// c2 = (v0 + beta * x0) / w'
///
/// dampingRatio == 1:
/// x(t) = exp(-beta * t) * (c1 + c2 * t)
/// c1 = x0
/// c2 = (v0 + beta * x0)
///
/// x0 - initial displacement
/// v0 - initial velocity
/// beta = damping / (2 * mass)
/// w0 = sqrt(stiffness / mass) - natural frequency
/// w' = sqrt(w0 * w0 - beta * beta) - damped natural frequency
public struct Spring {
    public var mass: CGFloat
    public var stiffness: CGFloat
    public var dampingRatio: CGFloat
    
    public init(mass: CGFloat, stiffness: CGFloat, dampingRatio: CGFloat) {
        self.mass = mass
        self.stiffness = stiffness
        self.dampingRatio = dampingRatio
    }
}

public extension Spring {
    
    static var `default`: Spring {
        return Spring(mass: 1, stiffness: 200, dampingRatio: 1)
    }
    
}

public extension Spring {
    
    var damping: CGFloat {
        return 2 * dampingRatio * sqrt(mass * stiffness)
    }
    
    var beta: CGFloat {
        return damping / (2 * mass)
    }
    
    var dampedNaturalFrequency: CGFloat {
        return sqrt(stiffness / mass) * sqrt(1 - dampingRatio * dampingRatio)
    }
    
}

public struct SpringTimingParameters {
    public let spring: Spring
    public let displacement: CGFloat
    public let initialVelocity: CGFloat
    public let threshold: CGFloat
    private let impl: DampingTimingParameters
        
    public init(spring: Spring, displacement: CGFloat, initialVelocity: CGFloat, threshold: CGFloat) {
        self.spring = spring
        self.displacement = displacement
        self.initialVelocity = initialVelocity
        self.threshold = threshold
        
        if spring.dampingRatio == 1 {
            self.impl = CriticallyDampedSpringTimingParameters(
                spring: spring,
                displacement: displacement,
                initialVelocity: initialVelocity,
                threshold: threshold
            )
        } else if spring.dampingRatio > 0, spring.dampingRatio < 1 {
            self.impl = UnderdampedSpringTimingParameters(
                spring: spring,
                displacement: displacement,
                initialVelocity: initialVelocity,
                threshold: threshold
            )
        } else {
            fatalError("dampingRatio should be greater than 0 and less than or equal to 1")
        }
    }
}

extension SpringTimingParameters: DampingTimingParameters {

    public var duration: TimeInterval {
        return impl.duration
    }
    
    public func value(at time: TimeInterval) -> CGFloat {
        return impl.value(at: time)
    }

    public func amplitude(at time: TimeInterval) -> CGFloat {
        return impl.amplitude(at: time)
    }
        
}

// MARK: - Private Impl
 
private struct UnderdampedSpringTimingParameters {
    let spring: Spring
    let displacement: CGFloat
    let initialVelocity: CGFloat
    let threshold: CGFloat
}

extension UnderdampedSpringTimingParameters: DampingTimingParameters {
    
    var duration: TimeInterval {
        if displacement == 0, initialVelocity == 0 {
            return 0
        }
        
        return TimeInterval(log((abs(c1) + abs(c2)) / threshold) / spring.beta)
    }
    
    func value(at time: TimeInterval) -> CGFloat {
        let t = CGFloat(time)
        let wd = spring.dampedNaturalFrequency
        return exp(-spring.beta * t) * (c1 * cos(wd * t) + c2 * sin(wd * t))
    }

    func amplitude(at time: TimeInterval) -> CGFloat {
        let t = CGFloat(time)
        return exp(-spring.beta * t) * (abs(c1) + abs(c2))
    }

    // MARK: - Private
    
    private var c1: CGFloat {
        return displacement
    }
    
    private var c2: CGFloat {
        return (initialVelocity + spring.beta * displacement) / spring.dampedNaturalFrequency
    }
    
}

private struct CriticallyDampedSpringTimingParameters {
    let spring: Spring
    let displacement: CGFloat
    let initialVelocity: CGFloat
    let threshold: CGFloat
}

extension CriticallyDampedSpringTimingParameters: DampingTimingParameters {
    
    var duration: TimeInterval {
        if displacement == 0, initialVelocity == 0 {
            return 0
        }
        
        let b = spring.beta
        let e = CGFloat(M_E)
         
        let t1 = 1 / b * log(2 * abs(c1) / threshold)
        let t2 = 2 / b * log(4 * abs(c2) / (e * b * threshold))
        
        return TimeInterval(max(t1, t2))
    }
    
    func value(at time: TimeInterval) -> CGFloat {
        let t = CGFloat(time)
        return exp(-spring.beta * t) * (c1 + c2 * t)
    }

    func amplitude(at time: TimeInterval) -> CGFloat {
        return abs(value(at: time))
    }

    // MARK: - Private
    
    private var c1: CGFloat {
        return displacement
    }
    
    private var c2: CGFloat {
        return initialVelocity + spring.beta * displacement
    }
    
}
