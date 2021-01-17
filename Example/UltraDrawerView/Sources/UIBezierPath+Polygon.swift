import UIKit

extension UIBezierPath {

    convenience init(polygonSides sides: Int, center: CGPoint, radius: CGFloat, offset: CGFloat = 0) {
        self.init()
        
        let points = UIBezierPath.polygonPoints(sides: sides, center: center, radius: radius, offset: offset)
        
        if points.count > 1 {
            move(to: points.first!)
            
            for i in 1 ..< points.count {
                addLine(to: points[i])
            }
            
            close()
        }
    }

    static func polygonPoints(sides: Int, center: CGPoint, radius: CGFloat, offset: CGFloat = 0)
        -> [CGPoint]
    {
        func toRadians(_ value: CGFloat) -> CGFloat {
            return value / 180 * .pi
        }
    
        let angle = toRadians(360 / CGFloat(sides))
        let cx = center.x
        let cy = center.y
        let r = radius
        let o = toRadians(offset)
        
        return (0 ..< sides).map { i in
            let xpo = cx + r * sin(angle * CGFloat(i) - o)
            let ypo = cy - r * cos(angle * CGFloat(i) - o)
            return CGPoint(x: xpo, y: ypo)
        }
    }
}
