import UIKit

final class ShapeHeaderView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    
        addSubview(button)
        button.tintColor = .black
        button.backgroundColor = .randomLight
        button.setTitle("Favourite shapes", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 24)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets.left = 16
        button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        addSubview(separator)
        separator.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let button = UIButton(type: .system)
    private let separator = UIView()
    
    @objc private func handleButton() {
        button.backgroundColor = .randomLight
    }

}
