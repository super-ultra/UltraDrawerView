import UIKit

internal extension UIView {
    
    @discardableResult
    func set(_ attribute: NSLayoutConstraint.Attribute, equalTo view: UIView, multiplier: CGFloat = 1,
        constant: CGFloat = 0, priority: UILayoutPriority = .required)
        -> NSLayoutConstraint
    {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: view,
            attribute: attribute, multiplier: multiplier, constant: constant)
        
        constraint.priority = priority
        constraint.isActive = true
        
        return constraint
    }
    
    @discardableResult
    func set(_ attributes: [NSLayoutConstraint.Attribute], equalTo view: UIView, multiplier: CGFloat = 1,
        constant: CGFloat = 0, priority: UILayoutPriority = .required)
        -> [NSLayoutConstraint]
    {
        return attributes.map { set($0, equalTo: view, multiplier: multiplier, constant: constant, priority: priority) }
    }
    
    @discardableResult
    func set(_ attribute: NSLayoutConstraint.Attribute, equalTo view: UIView,
        attribute toAttribute: NSLayoutConstraint.Attribute,
        multiplier: CGFloat = 1, constant: CGFloat = 0, priority: UILayoutPriority = .required)
        -> NSLayoutConstraint
    {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: view,
            attribute: toAttribute, multiplier: multiplier, constant: constant)
        
        constraint.priority = priority
        constraint.isActive = true
        
        return constraint
    }
    
    @discardableResult
    func set(_ attribute: NSLayoutConstraint.Attribute, equalTo value: CGFloat, priority: UILayoutPriority = .required)
        -> NSLayoutConstraint
    {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: nil,
            attribute: .notAnAttribute, multiplier: 0, constant: value)
        
        constraint.priority = priority
        constraint.isActive = true
        
        return constraint
    }
    
}
