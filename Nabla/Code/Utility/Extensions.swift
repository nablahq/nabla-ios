//
//  Extensions.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 28.08.2023..
//

import UIKit
import FirebaseAuth

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

extension Array where Element: Equatable {
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
    func withImage(direction: Direction, image: UIImage, colorSeparator: UIColor, colorBorder: UIColor) {
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
        
        if Direction.Left == direction { // image left
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

// MARK: - Extending a `Firebase User` to conform to `DataSourceProvidable`

//extension User: DataSourceProvidable {
//  private var infoSection: Section {
//    let items = [Item(title: providerID, detailTitle: "Provider ID"),
//                 Item(title: uid, detailTitle: "UUID"),
//                 Item(title: displayName ?? "––", detailTitle: "Display Name", isEditable: true),
//                 Item(
//                   title: photoURL?.absoluteString ?? "––",
//                   detailTitle: "Photo URL",
//                   isEditable: true
//                 ),
//                 Item(title: email ?? "––", detailTitle: "Email", isEditable: true),
//                 Item(title: phoneNumber ?? "––", detailTitle: "Phone Number")]
//    return Section(headerDescription: "Info", items: items)
//  }
//
//  private var metaDataSection: Section {
//    let metadataRows = [
//      Item(title: metadata.lastSignInDate?.description, detailTitle: "Last Sign-in Date"),
//      Item(title: metadata.creationDate?.description, detailTitle: "Creation Date"),
//    ]
//    return Section(headerDescription: "Firebase Metadata", items: metadataRows)
//  }
//
//  private var otherSection: Section {
//    let otherRows = [Item(title: isAnonymous ? "Yes" : "No", detailTitle: "Is User Anonymous?"),
//                     Item(title: isEmailVerified ? "Yes" : "No", detailTitle: "Is Email Verified?")]
//    return Section(headerDescription: "Other", items: otherRows)
//  }
//
//  private var actionSection: Section {
//    let actionsRows = [
//      Item(title: UserAction.refreshUserInfo.rawValue, textColor: .systemBlue),
//      Item(title: UserAction.signOut.rawValue, textColor: .systemBlue),
//      Item(title: UserAction.link.rawValue, textColor: .systemBlue, hasNestedContent: true),
//      Item(title: UserAction.requestVerifyEmail.rawValue, textColor: .systemBlue),
//      Item(title: UserAction.tokenRefresh.rawValue, textColor: .systemBlue),
//      Item(title: UserAction.delete.rawValue, textColor: .systemRed),
//    ]
//    return Section(headerDescription: "Actions", items: actionsRows)
//  }
//
//  var sections: [Section] {
//    [infoSection, metaDataSection, otherSection, actionSection]
//  }
//}

// MARK: - UIKit Extensions

extension UIViewController {
  public func displayError(_ error: Error?, from function: StaticString = #function) {
    guard let error = error else { return }
    print("ⓧ Error in \(function): \(error.localizedDescription)")
    let message = "\(error.localizedDescription)\n\n Ocurred in \(function)"
    let errorAlertController = UIAlertController(
      title: "Error",
      message: message,
      preferredStyle: .alert
    )
    errorAlertController.addAction(UIAlertAction(title: "OK", style: .default))
    present(errorAlertController, animated: true, completion: nil)
  }
}

extension UINavigationController {
  func configureTabBar(title: String, systemImageName: String) {
    let tabBarItemImage = UIImage(systemName: systemImageName)
    tabBarItem = UITabBarItem(title: title,
                              image: tabBarItemImage?.withRenderingMode(.alwaysTemplate),
                              selectedImage: tabBarItemImage)
  }

  enum titleType: CaseIterable {
    case regular, large
  }

  func setTitleColor(_ color: UIColor, _ types: [titleType] = titleType.allCases) {
    if types.contains(.regular) {
      navigationBar.titleTextAttributes = [.foregroundColor: color]
    }
    if types.contains(.large) {
      navigationBar.largeTitleTextAttributes = [.foregroundColor: color]
    }
  }
}

extension UITextField {
  func setImage(_ image: UIImage?) {
    guard let image = image else { return }
    let imageView = UIImageView(image: image)
    imageView.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
    imageView.contentMode = .scaleAspectFit

    let containerView = UIView()
    containerView.frame = CGRect(x: 20, y: 0, width: 40, height: 40)
    containerView.addSubview(imageView)
    leftView = containerView
    leftViewMode = .always
  }
}

extension UIImageView {
  convenience init(systemImageName: String, tintColor: UIColor? = nil) {
    var systemImage = UIImage(systemName: systemImageName)
    if let tintColor = tintColor {
      systemImage = systemImage?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
    }
    self.init(image: systemImage)
  }

  func setImage(from url: URL?) {
    guard let url = url else { return }
    DispatchQueue.global(qos: .background).async {
      guard let data = try? Data(contentsOf: url) else { return }

      let image = UIImage(data: data)
      DispatchQueue.main.async {
        self.image = image
        self.contentMode = .scaleAspectFit
      }
    }
  }
}

extension UIImage {
  static func systemImage(_ systemName: String, tintColor: UIColor) -> UIImage? {
    let systemImage = UIImage(systemName: systemName)
    return systemImage?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
  }
}

extension UIColor {
  static let highlightedLabel = UIColor.label.withAlphaComponent(0.8)

  var highlighted: UIColor { withAlphaComponent(0.8) }

  var image: UIImage {
    let pixel = CGSize(width: 1, height: 1)
    return UIGraphicsImageRenderer(size: pixel).image { context in
      self.setFill()
      context.fill(CGRect(origin: .zero, size: pixel))
    }
  }
}

// MARK: UINavigationBar + UserDisplayable Protocol

protocol UserDisplayable {
  func addProfilePic(_ imageView: UIImageView)
}

extension UINavigationBar: UserDisplayable {
  func addProfilePic(_ imageView: UIImageView) {
    let length = frame.height * 0.46
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = length / 2
    imageView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
      imageView.heightAnchor.constraint(equalToConstant: length),
      imageView.widthAnchor.constraint(equalToConstant: length),
    ])
  }
}

// MARK: Extending UITabBarController to work with custom transition animator

extension UITabBarController: UITabBarControllerDelegate {
  public func tabBarController(_ tabBarController: UITabBarController,
                               animationControllerForTransitionFrom fromVC: UIViewController,
                               to toVC: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
    let fromIndex = tabBarController.viewControllers!.firstIndex(of: fromVC)!
    let toIndex = tabBarController.viewControllers!.firstIndex(of: toVC)!

    let direction: Animator.TransitionDirection = fromIndex < toIndex ? .right : .left
    return Animator(direction)
  }

  func transitionToViewController(atIndex index: Int) {
    selectedIndex = index
  }
}

// MARK: - Foundation Extensions

extension Date {
  var description: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: self)
  }
}
