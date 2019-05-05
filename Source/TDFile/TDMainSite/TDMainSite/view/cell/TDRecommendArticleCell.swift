//
//  TDRecommendArticleCell.swift
//  edX
//
//  Created by Elite Edu on 2019/4/16.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDRecommendArticleCell: UICollectionViewCell {
    
    let bgView = UIView()
    
    let headerImage = UIImageView()
    let titleLabel = UILabel()
    let messageLabel = UILabel()
    let line = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setViewConstraint()
    }
    
    var model: TDMainSiteStoryModel? {
        didSet {
            titleLabel.text = model?.story_title
            messageLabel.text = model?.story_content
            if let array = model?.story_photo, array.count > 0,
                let host = OEXConfig.shared().apiHostURL()?.absoluteString {
                headerImage.sd_setImage(with: URL(string: "\(host)\(array[0])"), placeholderImage: UIImage(named: "main_article_image"))
            }
        }
    }
    
    func setViewConstraint() {
        bgView.backgroundColor = UIColor.white
        self.contentView.addSubview(bgView)
        
        headerImage.layer.masksToBounds = true
        headerImage.layer.cornerRadius = 4.0
        headerImage.image = UIImage(named: "main_article_image")
        bgView.addSubview(headerImage)
        
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor(hexString: "#2e313c")
        titleLabel.font = UIFont(name: "PingFang-SC-Medium", size: 15.0)
        bgView.addSubview(titleLabel)
        
        messageLabel.numberOfLines = 0
        messageLabel.textColor = UIColor(hexString: "#aab2bd")
        messageLabel.font = UIFont(name: "PingFang-SC-Regular", size: 12.0)
        bgView.addSubview(messageLabel)
        
        line.backgroundColor = UIColor(hexString: "#f5f5f5")
        bgView.addSubview(line)
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(self.contentView)
        }
        
        headerImage.snp.makeConstraints { (make) in
            make.right.equalTo(bgView).offset(-12)
            make.centerY.equalTo(bgView.snp.centerY)
            make.size.equalTo(CGSize(width: 130, height: 80))
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(12)
            make.right.equalTo(headerImage.snp.left).offset(-12)
            make.bottom.equalTo(headerImage.snp.bottom)
            make.height.equalTo(22)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerImage.snp.top)
            make.left.equalTo(messageLabel.snp.left)
            make.right.equalTo(messageLabel.snp.right)
            make.bottom.lessThanOrEqualTo(messageLabel.snp.top).offset(-5)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.right.equalTo(bgView)
            make.bottom.equalTo(bgView).offset(-1)
            make.height.equalTo(1.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
