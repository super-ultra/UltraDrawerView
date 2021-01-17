import CoreGraphics

internal extension CGPoint {
    
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
     
    func clamped(to rect: CGRect) -> CGPoint {
        return CGPoint(x: x.clamped(to: rect.minX ... rect.maxX), y: y.clamped(to: rect.minY ... rect.maxY))
    }
    
    func distance(to other: CGPoint) -> CGFloat {
        return (self - other).length
    }
    
    func distance(toSegment segment: (CGPoint, CGPoint)) -> CGFloat {
        let v = segment.0
        let w = segment.1
    
        let pv_dx = x - v.x
        let pv_dy = y - v.y
        let wv_dx = w.x - v.x
        let wv_dy = w.y - v.y

        let dot = pv_dx * wv_dx + pv_dy * wv_dy
        let len_sq = wv_dx * wv_dx + wv_dy * wv_dy
        let param = dot / len_sq

        var int_x, int_y: CGFloat /* intersection of normal to vw that goes through p */

        if param < 0 || (v.x == w.x && v.y == w.y) {
            int_x = v.x
            int_y = v.y
        } else if param > 1 {
            int_x = w.x
            int_y = w.y
        } else {
            int_x = v.x + param * wv_dx
            int_y = v.y + param * wv_dy
        }

        /* Components of normal */
        let dx = x - int_x
        let dy = y - int_y

        return sqrt(dx * dx + dy * dy)
    }
    
}

internal extension CGPoint {
    
    static prefix func - (lhs: CGPoint) -> CGPoint {
        return CGPoint(x: -lhs.x, y: -lhs.y)
    }
    
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func * (lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs * rhs.x, y: lhs * rhs.y)
    }
    
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return rhs * lhs
    }
    
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
}
