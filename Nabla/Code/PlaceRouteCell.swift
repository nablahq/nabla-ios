//
//  PlaceRouteCell.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 22.08.2023..
//

import UIKit

protocol PlaceRouteCellDelegate {
    func cellTapped(cell: PlaceRouteCell)
}

protocol PlaceRouteLabelDelegate {
    func cellLabelTapped(cell: PlaceRouteCell)
}

class PlaceRouteCell: UITableViewCell {

    lazy var labelName : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .white
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellLabelTapped)))
        return label
    }()
    
    lazy var cellView: UIView = {
        let view = UITableView()
        view.backgroundColor = .white
        view.tintColor = .blue
        view.isScrollEnabled = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.tintColor = .black
        button.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        button.addTarget(self, action: #selector(cellTapped), for: .touchUpInside)
        return button
    }()
    
    var cellButtonDelegate: PlaceRouteCellDelegate?
    var cellLabelDelegate: PlaceRouteLabelDelegate?
    
    var index: Int = 0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        

        contentView.addSubview(cellView)
        contentView.addSubview(labelName)
        contentView.addSubview(actionButton)
        
        cellView.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 10, leftConstant: 16, bottomConstant: 5, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        
        labelName.anchor(cellView.topAnchor, left: cellView.leftAnchor, bottom: cellView.bottomAnchor, right: nil, topConstant: 5, leftConstant: 12, bottomConstant: 5, rightConstant: 0, widthConstant: 200, heightConstant: 0)
        
        actionButton.anchor(cellView.topAnchor, left: nil, bottom: cellView.bottomAnchor, right: cellView.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 5, rightConstant: 12, widthConstant: 30, heightConstant: 0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func cellTapped(sender: AnyObject) {
        if let delegate = cellButtonDelegate {
            delegate.cellTapped(cell: self)
        }
    }
    
    @objc func cellLabelTapped(sender: AnyObject) {
        if let delegate = cellLabelDelegate {
            delegate.cellLabelTapped(cell: self)
        }
    }
}
