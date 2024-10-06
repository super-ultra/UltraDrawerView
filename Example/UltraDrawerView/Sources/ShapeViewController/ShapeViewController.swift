import UIKit
import UltraDrawerView

final class ShapeViewController: UIViewController {

    private enum Layout {
        static let topInsetPortrait: CGFloat = 36
        static let topInsetLandscape: CGFloat = 20
        static let middleInsetFromBottom: CGFloat = 280
        static let headerHeight: CGFloat = 64
        static let cornerRadius: CGFloat = 16
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Float = 0.2
        static let shadowOffset = CGSize.zero
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        let headerView = ShapeHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: Layout.headerHeight).isActive = true
        
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ShapeCell.self, forCellReuseIdentifier: "\(ShapeCell.self)")
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        
        drawerView = DrawerView(scrollView: tableView, headerView: headerView)
        drawerView.middlePosition = .fromBottom(Layout.middleInsetFromBottom)
        drawerView.cornerRadius = Layout.cornerRadius
        drawerView.containerView.backgroundColor = .white
        drawerView.layer.shadowRadius = Layout.shadowRadius
        drawerView.layer.shadowOpacity = Layout.shadowOpacity
        drawerView.layer.shadowOffset = Layout.shadowOffset

        view.addSubview(drawerView)
        
        setupButtons()
        setupLayout()
        
        drawerView.setState(.middle, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isFirstLayout {
            isFirstLayout = false
            updateLayoutWithCurrentOrientation()
            drawerView.setState(UIDevice.current.orientation.isLandscape ? .top : .middle, animated: false)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let prevState = drawerView.state
        
        updateLayoutWithCurrentOrientation()
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            let newState: DrawerView.State = (prevState == .bottom) ? .bottom : .top
            self?.drawerView.setState(newState, animated: context.isAnimated)
        })
    }
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
        tableView.verticalScrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
    }
    
    // MARK: - Private
    
    private let tableView = UITableView()
    private var drawerView: DrawerView!
    private let cellInfos = ShapeCell.makeDefaultInfos()
    private var isFirstLayout = true
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    private func setupLayout() {
        drawerView.translatesAutoresizingMaskIntoConstraints = false
    
        portraitConstraints = [
            drawerView.topAnchor.constraint(equalTo: view.topAnchor),
            drawerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            drawerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            drawerView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ]
        
        let landscapeLeftAnchor: NSLayoutXAxisAnchor
        if #available(iOS 11.0, *) {
            landscapeLeftAnchor = view.safeAreaLayoutGuide.leftAnchor
        } else {
            landscapeLeftAnchor = view.leftAnchor
        }
        
        landscapeConstraints = [
            drawerView.topAnchor.constraint(equalTo: view.topAnchor),
            drawerView.leftAnchor.constraint(equalTo: landscapeLeftAnchor, constant: 16),
            drawerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            drawerView.widthAnchor.constraint(equalToConstant: 320),
        ]
    }
    
    private func updateLayoutWithCurrentOrientation() {
        let orientation = UIDevice.current.orientation
        
        if orientation.isLandscape {
            portraitConstraints.forEach { $0.isActive = false }
            landscapeConstraints.forEach { $0.isActive = true }
            drawerView.topPosition = .fromTop(Layout.topInsetLandscape)
            drawerView.availableStates = [.top, .bottom]
        } else if orientation.isPortrait {
            landscapeConstraints.forEach { $0.isActive = false }
            portraitConstraints.forEach { $0.isActive = true }
            drawerView.topPosition = .fromTop(Layout.topInsetPortrait)
            drawerView.availableStates = [.top, .middle, .bottom]
        }
    }

}

extension ShapeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(ShapeCell.self)", for: indexPath)
        
        if let cell = cell as? ShapeCell {
            cell.update(with: cellInfos[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return ShapeCell.Layout.estimatedHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ShapeViewController {

    // MARK: - Buttons
    
    private func setupButtons() {
        func addButton(withTitle title: String, action: Selector, topPosition: CGFloat) {
            let button = UIButton(type: .system)
            view.addSubview(button)
            button.backgroundColor = .darkGray
            button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
            button.tintColor = .white
            button.layer.cornerRadius = 8
            button.layer.masksToBounds = true
            
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: action, for: .touchUpInside)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            let rightAnchor: NSLayoutXAxisAnchor
            let topAnchor: NSLayoutYAxisAnchor
            if #available(iOS 11.0, *) {
                rightAnchor = view.safeAreaLayoutGuide.rightAnchor
                topAnchor = view.safeAreaLayoutGuide.topAnchor
            } else {
                rightAnchor = view.rightAnchor
                topAnchor = view.topAnchor
            }
            
            button.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
            button.widthAnchor.constraint(equalToConstant: 128).isActive = true
            button.topAnchor.constraint(equalTo: topAnchor, constant: topPosition).isActive = true
        }
    
        addButton(withTitle: "Hide", action: #selector(handleHideButton), topPosition: 32)
        addButton(withTitle: "Show", action: #selector(handleShowButton), topPosition: 64 + 32)
        addButton(withTitle: "Middle", action: #selector(handleMiddleButton), topPosition: 2 * 64 + 32)
    }
    
    @objc private func handleHideButton() {
        drawerView.setState(.bottom, animated: true)
    }
    
    @objc private func handleShowButton() {
        drawerView.setState(.top, animated: true)
    }
    
    @objc private func handleMiddleButton() {
        drawerView.setState(.middle, animated: true)
    }
    
}
