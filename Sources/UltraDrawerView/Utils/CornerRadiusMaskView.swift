import UIKit

internal final class CornerRadiusMaskView: UIImageView {
    
    let radius: CGFloat

    init(radius: CGFloat) {
        self.radius = radius
        super.init(frame: .zero)
        image = UIImage.make(byRoundingCorners: [.topLeft, .topRight], radius: radius)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
