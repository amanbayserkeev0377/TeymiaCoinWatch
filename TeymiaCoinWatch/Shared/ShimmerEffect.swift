import UIKit

extension UIView {
    func startShimmering() {
        let light = UIColor.systemGray6.cgColor
        let dark = UIColor.systemGray5.cgColor
        
        let gradient = CAGradientLayer()
        gradient.colors = [light, dark, light]
        gradient.frame = CGRect(x: -self.bounds.width, y: 0, width: self.bounds.width * 3, height: self.bounds.height)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.locations = [0.0, 0.5, 1.0]
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.0, 0.25]
        animation.toValue = [0.75, 1.0, 1.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        
        gradient.add(animation, forKey: "shimmer")
        self.layer.addSublayer(gradient)
        self.layer.name = "shimmerLayer"
    }
    
    func stopShimmering() {
        self.layer.sublayers?.removeAll(where: { $0.animation(forKey: "shimmer") != nil })
    }
}
