//
//  SettingsCell.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 25.08.2023..
//

import UIKit

protocol SettingsCellDelegate {
    func cellTapped(cell: SettingsCell)
}

class SettingsCell: UITableViewCell {

    let labelName : UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.backgroundColor = .white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let labelSelectedOption : UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.backgroundColor = .white
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.tintColor = .darkGray
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
//        button.addTarget(self, action: #selector(cellTapped), for: .touchUpInside)
        return button
    }()
    
    let tapLabel : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var cellButtonDelegate: SettingsCellDelegate?
    
    var id: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(labelSelectedOption)
        contentView.addSubview(labelName)
        contentView.addSubview(actionButton)
        contentView.addSubview(tapLabel)
        
        labelName.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: nil, topConstant: 5, leftConstant: 12, bottomConstant: 5, rightConstant: 0, widthConstant: 200, heightConstant: 0)
        
        actionButton.anchor(contentView.topAnchor, left: nil, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 5, rightConstant: 12, widthConstant: 30, heightConstant: 0)
        
        labelSelectedOption.anchor(contentView.topAnchor, left: nil, bottom: contentView.bottomAnchor, right: actionButton.leftAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 5, rightConstant: 0, widthConstant: 150, heightConstant: 0)
        
        tapLabel.fillSuperview()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped))
        tapLabel.addGestureRecognizer(tap)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func cellTapped(sender: AnyObject) {
        if let delegate = cellButtonDelegate {
            delegate.cellTapped(cell: self)
        }
    }
}
