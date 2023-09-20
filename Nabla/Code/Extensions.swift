//
//  Extensions.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 28.08.2023..
//

import UIKit

extension Array {

    public func safelyAccessElement(at index: Int) -> Element? {
        guard (0..<count).contains(index) else {
            return nil
        }

        return self[index]
    }
    
    public mutating func move(from oldIndex: Index, to newIndex: Index) {
        // Don't work for free and use swap when indices are next to each other - this
        // won't rebuild array and will be super efficient.
        if oldIndex == newIndex { return }
        if abs(newIndex - oldIndex) == 1 { return self.swapAt(oldIndex, newIndex) }
        self.insert(self.remove(at: oldIndex), at: newIndex)
    }

}

extension Array where Element: Equatable
{
    public mutating func move(_ element: Element, to newIndex: Index) {
        if let oldIndex: Int = self.firstIndex(of: element) { self.move(from: oldIndex, to: newIndex) }
    }
}


extension UITextField {
    
    enum Direction {
        case Left
        case Right
    }
    
    // add image to textfield
    func withImage(direction: Direction, image: UIImage, colorSeparator: UIColor, colorBorder: UIColor){
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
        mainView.layer.cornerRadius = 15
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 0
        view.layer.borderColor = colorBorder.cgColor
        mainView.addSubview(view)
        
        let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 12.0, y: 10.0, width: 24.0, height: 24.0)
        view.addSubview(imageView)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = colorSeparator
        mainView.addSubview(seperatorView)
        
        if(Direction.Left == direction){ // image left
            seperatorView.frame = CGRect(x: 45, y: 0, width: 5, height: 45)
            self.leftViewMode = .always
            self.leftView = mainView
        } else { // image right
            seperatorView.frame = CGRect(x: 0, y: 0, width: 5, height: 45)
            self.rightViewMode = .always
            self.rightView = mainView
        }
        
        self.layer.borderColor = colorBorder.cgColor
        self.layer.borderWidth = CGFloat(0.5)
        self.layer.cornerRadius = 15
    }
    
}

extension UserDefaults {
    static func resetDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}




extension UIViewController {

    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = .push
        transition.subtype = .fromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)

        present(viewControllerToPresent, animated: false)
    }

    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = .push
        transition.subtype = .fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)

        dismiss(animated: false)
    }
}

@nonobjc extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect) {
        addChild(child)
        
        child.view.frame = frame
        
        view.addSubview(child.view)
        
        child.view.transform = CGAffineTransform(translationX: 0, y: frame.height)
        
        UIView.animate(withDuration: 0.28, delay: 0.1, options: .curveEaseInOut, animations: {
            child.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { _ in
            child.didMove(toParent: self)
        })
    }

    func remove(frame: CGRect) {
        willMove(toParent: nil)
        
        view.transform = CGAffineTransform(translationX: 0, y: 0)
        UIView.animate(withDuration: 0.28, delay: 0.1, options: .curveEaseInOut, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: frame.height)
        }, completion: { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
}
