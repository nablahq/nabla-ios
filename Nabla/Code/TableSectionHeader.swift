//
//  TableSectionHeader.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 22.08.2023..
//

import UIKit

protocol AddPlaceButtonDelegate {
    func addPlaceButtonPressed(header: TableSectionHeader)
}

class TableSectionHeader: UITableViewHeaderFooterView {
    
    let title = UILabel()
    let image = UIImageView()
    
    var buttonVisible: Bool! {
        didSet {
            configureContents()
        }
    }
    
    lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle(" Add place", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.tintColor = .black
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.semanticContentAttribute = .forceLeftToRight
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        button.layer.masksToBounds = false
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 0.5
        button.addTarget(self, action: #selector(addPlaceButtonPressed), for: .touchUpInside)
        return button
    }()
    
    var addPlaceButtonDelegate: AddPlaceButtonDelegate?

    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configureContents() {
        image.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        
        
        contentView.addSubview(image)
        contentView.addSubview(title)
        
        title.font = UIFont.systemFont(ofSize: 13)
        title.textColor = .darkGray

        // Center the image vertically and place it near the leading
        // edge of the view. Constrain its width and height to 50 points.
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            image.widthAnchor.constraint(equalToConstant: 25),
            image.heightAnchor.constraint(equalToConstant: 25),
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Center the label vertically, and use it to fill the remaining
            // space in the header view.
            title.heightAnchor.constraint(equalToConstant: 30),
            title.leadingAnchor.constraint(equalTo: image.trailingAnchor,
                                           constant: 8),
            title.trailingAnchor.constraint(equalTo:
                                                contentView.layoutMarginsGuide.trailingAnchor),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            
        ])
        
        if (buttonVisible == true)
        {
            addButton.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(addButton)
            addButton.anchor(contentView.topAnchor, left: nil, bottom: nil, right: contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 16, widthConstant: 105, heightConstant: 25)
        }
    }
    
    @objc func addPlaceButtonPressed(sender: AnyObject) {
        if let delegate = addPlaceButtonDelegate {
            delegate.addPlaceButtonPressed(header: self)
        }
    }
}
