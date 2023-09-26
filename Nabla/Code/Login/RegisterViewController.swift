//
//  RegisterViewController.swift
//  Nabla
//
//  Created by Jaksa Tomovic on 25.09.2023..
//  Copyright © 2023 canarin team. All rights reserved.
//

import Assets
import Networking
import Toolbox
import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    weak var delegate: LoginDelegate?
    var onLogin: (() -> Void)!
    
    static func create() -> RegisterViewController {
        let viewController = RegisterViewController()
        return viewController
    }
    
    private var registerView: RegisterView { view as! RegisterView }
    
    private var email: String { registerView.emailTextField.text! }
    private var password: String { registerView.passwordTextField.text! }
    
    // Hides tab bar when view controller is presented
    override var hidesBottomBarWhenPushed: Bool { get { true } set {} }
    
    // MARK: - View Controller Lifecycle Methods
    
    override func loadView() {
        view = RegisterView()
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
    
    private func createUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            print(authResult as Any)
            guard error == nil else { return self.displayError(error) }
            print("User created successfully")
            let userInfo = authResult?.user
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
    private func handleCreateAccount() {
        createUser(email: email, password: password)
    }
    
    @objc
    private func handleBackButton() {
        self.dismiss(animated: true)
    }
    
    // MARK: - UI Configuration
    
    private func configureNavigationBar() {
        navigationItem.title = "Create acccount"
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func configureDelegatesAndHandlers() {
        registerView.emailTextField.delegate = self
        registerView.passwordTextField.delegate = self
        registerView.loginButton.addTarget(self, action: #selector(handleCreateAccount), for: .touchUpInside)
        registerView.backButton.addTarget(
            self,
            action: #selector(handleBackButton),
            for: .touchUpInside
        )
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        registerView.emailTopConstraint.constant = UIDevice.current.orientation.isLandscape ? 15 : 50
        registerView.passwordTopConstraint.constant = UIDevice.current.orientation.isLandscape ? 5 : 20
    }
}

// MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if registerView.emailTextField.isFirstResponder, registerView.passwordTextField.text!.isEmpty {
            registerView.passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
