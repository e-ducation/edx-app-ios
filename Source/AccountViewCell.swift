//
//  AccountViewCell.swift
//  edX
//
//  Created by Salman on 15/08/2017.
//  Copyright © 2017 edX. All rights reserved.
//

import UIKit

class AccountViewCell: UITableViewCell {

    static let identifier = "accountViewCellIdentifier"
    private var titleLabel = UILabel()
    private var iconImage = UIImageView()
    private var messageLabel = UILabel()

    private let titleStyle = OEXTextStyle(weight: .normal, size: .large, color : UIColor(hexString: "#2e313c"))
    public var title : String? {
        didSet {
            titleLabel.attributedText = titleStyle.attributedString(withText: title)
            titleLabel.accessibilityIdentifier = "AccountViewController:title-title"
        }
    }

    private let messageStyle = OEXTextStyle(weight: .light, size: .large, color : OEXStyles.shared().neutralBase())
    public var mesage : String? {
        didSet {
            messageLabel.attributedText = messageStyle.attributedString(withText: mesage)
            messageLabel.accessibilityIdentifier = "AccountViewController:title-message"
        }
    }

    public var imageStr : String? {
        didSet {
            iconImage.image = UIImage(named: imageStr ?? "menbership_image")
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.white

        iconImage.contentMode = .scaleAspectFit
        contentView.addSubview(iconImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)

        iconImage.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(16)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(53)
            make.right.equalTo(contentView)
        }

        messageLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
