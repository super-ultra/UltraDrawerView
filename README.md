# UltraDrawerView

```swift
let headerView = HeaderView()
headerView.translatesAutoresizingMaskIntoConstraints = false
headerView.heightAnchor.constraint(equalToConstant: 64).isActive = true

let tableView = UITableView()

let drawerView = DrawerView(scrollView: tableView, headerView: headerView)
drawerView.availableStates = [.top, .middle, .bottom]
drawerView.middlePosition = .fromBottom(256)
drawerView.cornerRadius = 16
drawerView.containerView.backgroundColor = .white
drawerView.setState(.middle, animated: false)

// More fluctuations 
drawerView.animationParameters = .spring(mass: 1, stiffness: 200, dampingRatio: 0.5)

// Default UIScrollView like behavior
drawerView.animationParameters = .spring(.default)

```

## Example

![Example](Example/example.gif)

To run the example project, clone the repo and run `bundle exec pod install` from the Example directory first.

## Installation

UltraDrawerView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'UltraDrawerView'
```

## Author

Ilya Lobanov

## License

UltraDrawerView is available under the MIT license. See the LICENSE file for more info.
