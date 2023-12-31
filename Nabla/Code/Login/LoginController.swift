//
//  LoginController.swift
//  Nabla
//
//  Created by Jaksa Tomovic on 20.09.2023..
//  Copyright © 2023 canarin team. All rights reserved.
//

import Assets
import Networking
import Toolbox
import UIKit
import FirebaseAuth

class LoginController: UIViewController {
    weak var delegate: LoginDelegate?
    var onLogin: (() -> Void)!
    
    static func create() -> LoginController {
        let viewController = LoginController()
        return viewController
    }
    
    private var loginView: LoginView { view as! LoginView }
    
    private var email: String { loginView.emailTextField.text! }
    private var password: String { loginView.passwordTextField.text! }
    
    // Hides tab bar when view controller is presented
    override var hidesBottomBarWhenPushed: Bool { get { true } set {} }
    
    // MARK: - View Controller Lifecycle Methods
    
    override func loadView() {
        view = LoginView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureDelegatesAndHandlers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setTitleColor(.label)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        navigationController?.setTitleColor(.black)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.popViewController(animated: false)
    }
    
    // Dismisses keyboard when view is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Firebase 🔥
    
    private func login(with email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            print(result as Any)
            guard error == nil else { return self.displayError(error) }
            print("User signs in successfully")
            let userInfo = Auth.auth().currentUser
            let email = userInfo?.email
            print(email!)
            self.delegate?.loginDidOccur()
            let token: String = userInfo!.refreshToken!
            CredentialsController.shared.currentCredentials = Credentials(accessToken: token, refreshToken: token, expiresIn: nil)
            self.connectDevice()
        }
    }
    
    private func connectDevice() {
        let viewController = BLEController.create()
        viewController.onLogin = onLogin
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .fullScreen
        
        present(viewController, animated: false)
    }
    
    // MARK: - Action Handlers
    
    @objc
    private func handleLogin() {
        login(with: email, password: password)
    }
    
    @objc
    private func handleBackButton() {
        self.dismiss(animated: true)
    }
    
    // MARK: - UI Configuration
    
    private func configureNavigationBar() {
        navigationItem.title = "Sign in"
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func configureDelegatesAndHandlers() {
        loginView.emailTextField.delegate = self
        loginView.passwordTextField.delegate = self
        loginView.loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginView.backButton.addTarget(
            self,
            action: #selector(handleBackButton),
            for: .touchUpInside
        )
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        loginView.emailTopConstraint.constant = UIDevice.current.orientation.isLandscape ? 15 : 50
        loginView.passwordTopConstraint.constant = UIDevice.current.orientation.isLandscape ? 5 : 20
    }
}

// MARK: - UITextFieldDelegate

extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if loginView.emailTextField.isFirstResponder, loginView.passwordTextField.text!.isEmpty {
            loginView.passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
