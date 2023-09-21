//
//  AuthenticationController.swift
//  Nabla
//
//  Created by Jaksa Tomovic on 20.09.2023..
//  Copyright © 2023 canarin team. All rights reserved.
//

import UIKit
import Networking
import FirebaseAuth

class AuthenticationController: UIViewController {
    
    // MARK: Interface
    
    var onLogin: (() -> Void)!
    
    static func create() -> AuthenticationController {
        let viewController = AuthenticationController()
        return viewController
    }
    
    lazy var skipLoginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.tintColor =  .white
        button.setTitle("Skip account setup (Limited access)", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(skipLoginButtonTapped), for: .touchUpInside)
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        button.layer.masksToBounds = false
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 0.5
        return button
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.tintColor =  .white
        button.setTitle("Create account / sign-in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        button.layer.masksToBounds = false
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 0.5
        return button
    }()
    
    lazy var logoImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "arrowtriangle.down"))
        view.backgroundColor = UIColor(white: 1.0, alpha: 0)
        view.contentMode = .scaleAspectFit
        view.tintColor = .black
        return view
    }()
    
    lazy var dotsImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "dots")?.withRenderingMode(.alwaysTemplate))
        view.backgroundColor = UIColor(white: 0.5, alpha: 0)
        view.contentMode = .scaleToFill
        view.tintColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.6)
        return view
    }()
    
    let labelTitle: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Nabla"
        label.textColor = .black
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let labelSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Routes, navigation and tracking for better\njourneys on two wheels"
        label.textColor = .black
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let footerLabel: UILabel = {
        let label = UILabel()
        label.text = "We require an acccount to store your infomration.\nView our jargon-free privacy policya and terms"
        label.textColor = .black
        label.backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .ultraLight)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.titleView?.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(dotsImageView)
        view.addSubview(logoImageView)
        view.addSubview(labelTitle)
        view.addSubview(labelSubtitle)
        view.addSubview(loginButton)
        view.addSubview(skipLoginButton)
        view.addSubview(footerLabel)
        
        dotsImageView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: view.frame.height/2)
        logoImageView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: view.safeAreaInsets.top + 80, leftConstant: view.frame.width/2 - 40, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: 80)
        labelTitle.anchor(logoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 15, leftConstant: 24, bottomConstant: 0, rightConstant: 24, widthConstant: 0, heightConstant: 35)
        labelSubtitle.anchor(labelTitle.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 15, leftConstant: 24, bottomConstant: 0, rightConstant: 24, widthConstant: 0, heightConstant: 60)
        
        loginButton.anchor(view.centerYAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 120, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 200, heightConstant: 50)
        skipLoginButton.anchor(loginButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 50)
        
        footerLabel.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: view.safeAreaInsets.bottom + 30, rightConstant: 16, widthConstant: 0, heightConstant: 50)
    }
    
    // MARK: - Action Handlers
    
    @objc private func skipLoginButtonTapped() {
        Auth.auth().signInAnonymously { result, error in
            guard error == nil else { return self.displayError(error) }
            CredentialsController.shared.currentCredentials = Credentials(accessToken: "testToken", refreshToken: result?.user.refreshToken, expiresIn: nil)
            self.onLogin()
        }
    }
    
    @objc private func loginButtonTapped() {
        let viewController = LoginController.create()
        viewController.onLogin = onLogin
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .fullScreen
        
        present(viewController, animated: true)
    }
}
