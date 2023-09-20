import UIKit

class SearchResultCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var pinImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "mappin")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = .black
        return iv
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(pinImageView)
        
        pinImageView.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, topConstant: 5, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        titleLabel.anchor(contentView.topAnchor, left: pinImageView.rightAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        subtitleLabel.anchor(titleLabel.bottomAnchor, left: pinImageView.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 5, rightConstant: 12, widthConstant: 0, heightConstant: 25)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
