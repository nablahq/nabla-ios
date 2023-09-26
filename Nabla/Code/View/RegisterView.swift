//
//  RegisterView.swift
//  Nabla
//
//  Created by Jaksa Tomovic on 21.09.2023..
//  Copyright © 2023 canarin team. All rights reserved.
//

import UIKit

class RegisterView: UIView {
    var emailTextField: UITextField! {
        didSet {
            emailTextField.textContentType = .emailAddress
        }
    }
    
    var passwordTextField: UITextField! {
        didSet {
            passwordTextField.textContentType = .password
        }
    }
    
    var emailTopConstraint: NSLayoutConstraint!
    var passwordTopConstraint: NSLayoutConstraint!
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.layer.cornerRadius = 14
        return button
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setTitle("Back", for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create account"
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    convenience init() {
        self.init(frame: .zero)
        setupSubviews()
    }
    
    // MARK: - Subviews Setup
    
    private func setupSubviews() {
        backgroundColor = .white
        clipsToBounds = true
        
        setupTitleLabel()
        setupEmailTextfield()
        setupPasswordTextField()
        setupLoginButton()
        setupBackButton()
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        
        titleLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: safeAreaInsets.top + 80, leftConstant: 22, bottomConstant: 0, rightConstant: 22, widthConstant: 0, heightConstant: 50)
    }
    
    private func setupEmailTextfield() {
        emailTextField = textField(placeholder: "Type your email here", symbolName: "person.crop.circle")
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emailTextField)
    
        emailTextField.anchor(titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 45)
    }
    
    private func setupPasswordTextField() {
        passwordTextField = textField(placeholder: "Type your password here", symbolName: "lock.fill")
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(passwordTextField)
        
        passwordTextField.anchor(emailTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 45)
    }
    
    private func setupLoginButton() {
        addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
   
        loginButton.anchor(passwordTextField.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 15, widthConstant: 90, heightConstant: 30)
    }
    
    private func setupBackButton() {
        addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
 
        backButton.anchor(passwordTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 30, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: 30)
    }
    
    // MARK: - Private Helpers
    
    private func textField(placeholder: String, symbolName: String) -> UITextField {
        let textfield = UITextField()
        textfield.backgroundColor = .secondarySystemBackground
        textfield.layer.cornerRadius = 14
        textfield.placeholder = placeholder
        textfield.tintColor = .black
        let symbol = UIImage(systemName: symbolName)
        textfield.setImage(symbol)
        return textfield
    }
}
