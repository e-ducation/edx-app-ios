//
//  TDMainProfessorCell.swift
//  edX
//
//  Created by Elite Edu on 2019/4/16.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDMainProfessorCell: UICollectionViewCell {
    
    let bgView = UIView()
    
    let headerImage = UIImageView()
    let nameLabel = UILabel()
    let messageLabel = UILabel()
    
    var model: TDMainSiteProfessorModel? {
        didSet {
            nameLabel.text = model?.name
            messageLabel.text = model?.content
            headerImage.sd_setImage(with: URL(string: model?.professor_pic ?? ""), placeholderImage: UIImage(named: "person_box_image"))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setViewConstraint()
    }
    
    func setViewConstraint() {
        bgView.backgroundColor = UIColor.white
        self.contentView.addSubview(bgView)
        
        headerImage.layer.masksToBounds = true
        headerImage.layer.cornerRadius = 4.0
        headerImage.image = UIImage(named: "person_box_image")
        bgView.addSubview(headerImage)
        
        nameLabel.textColor = UIColor(hexString: "#2e313c")
        nameLabel.font = UIFont(name: "PingFang-SC-Medium", size: 15.0)
        bgView.addSubview(nameLabel)
        
        messageLabel.numberOfLines = 0
        messageLabel.textColor = UIColor(hexString: "#999999")
        messageLabel.font = UIFont(name: "PingFang-SC-Regular", size: 14.0)
        bgView.addSubview(messageLabel)
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(self.contentView)
        }
        
        headerImage.snp.makeConstraints { (make) in
            make.left.equalTo(bgView.snp.left).offset(12)
            make.centerY.equalTo(bgView.snp.centerY)
            make.size.equalTo(CGSize(width: 74, height: 74))
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerImage.snp.top)
            make.left.equalTo(headerImage.snp.right).offset(12)
            make.right.equalTo(bgView.snp.right).offset(-12)
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalTo(nameLabel.snp.right)
            make.top.equalTo(nameLabel.snp.bottom)
            make.bottom.lessThanOrEqualTo(headerImage.snp.bottom)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
