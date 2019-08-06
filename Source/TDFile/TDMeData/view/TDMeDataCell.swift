//
//  TDMeDataCell.swift
//  edX
//
//  Created by Elite Edu on 2019/7/25.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDMeDataCell: UITableViewCell {
    
    static let identifier = "TDMeDataCell"
    
    private var headerImage = ProfileImageView()
    private var titleLabel = UILabel()
    private var messageLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configView()
        setViewConstraint()
    }
    
    func showProfileData(profile: UserProfile, networkManager: NetworkManager) {
        headerImage.remoteImage = profile.image(networkManager: networkManager)
        titleLabel.text = profile.username
    }
    
    func configView() {
        backgroundColor = UIColor.white
        
        headerImage.contentMode = .scaleAspectFit
        contentView.addSubview(headerImage)
        
        titleLabel.font = UIFont(name: "PingFang-SC-Medium", size: 18)
        titleLabel.textColor = UIColor(hexString: "#2e313c")
        contentView.addSubview(titleLabel)
        
        messageLabel.font = UIFont(name: "PingFang-SC-Regular", size: 12)
        messageLabel.textColor = UIColor(hexString: "#bfc1c9")
        contentView.addSubview(messageLabel)
        
        titleLabel.text = ""
        messageLabel.text = Strings.editeInfo
    }
    
    func setViewConstraint() {
        headerImage.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(16)
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(headerImage.snp.centerY)
            make.left.equalTo(headerImage.snp.right).offset(12)
            make.right.equalTo(contentView).offset(-12)
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.left.right.equalTo(titleLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
