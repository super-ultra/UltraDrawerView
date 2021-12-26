import UIKit

final class ShapeCell: UITableViewCell {

    struct Info {
        var title: String
        var subtitle: String
        var shape: UIBezierPath
    }
    
    enum Layout {
        static let inset: CGFloat = 18
        static let shapeSize: CGFloat = 48
        static let estimatedHeight: CGFloat = 40
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with info: Info) {
        self.info = info
     
        titleLabel.text = info.title
        subtitleLabel.text = info.subtitle
        shapeLayer.path = info.shape.cgPath
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = shapeButton.bounds
    }
    
    // MARK: - Private
    
    private let shapeButton = UIButton()
    private let shapeLayer = CAShapeLayer()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var info: Info?
    
    private func setupViews() {
        backgroundColor = .white
        
        contentView.addSubview(shapeButton)
        shapeButton.addTarget(self, action: #selector(handleShapeButton), for: .touchUpInside)
        
        shapeButton.layer.addSublayer(shapeLayer)
        shapeLayer.lineWidth = 5
        shapeLayer.lineJoin = .round
        updateShapeColors()
        
        contentView.addSubview(titleLabel)
        titleLabel.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        
        contentView.addSubview(subtitleLabel)
        subtitleLabel.font = .systemFont(ofSize: UIFont.systemFontSize)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .darkGray
        
        setupLayout()
    }
    
    private func setupLayout() {
        let inset = Layout.inset
        let shapeSize = Layout.shapeSize
        
        shapeButton.translatesAutoresizingMaskIntoConstraints = false
        shapeButton.widthAnchor.constraint(equalToConstant: shapeSize).isActive = true
        shapeButton.heightAnchor.constraint(equalToConstant: shapeSize).isActive = true
        shapeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset).isActive = true
        shapeButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: inset).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leftAnchor.constraint(equalTo: shapeButton.rightAnchor, constant: inset).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -inset).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset).isActive = true
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.leftAnchor.constraint(equalTo: shapeButton.rightAnchor, constant: inset).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -inset).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func updateShapeColors() {
        shapeLayer.fillColor = UIColor.randomLight.cgColor
        shapeLayer.strokeColor = UIColor.randomDark.cgColor
    }
    
    @objc private func handleShapeButton() {
        updateShapeColors()
    }

}
