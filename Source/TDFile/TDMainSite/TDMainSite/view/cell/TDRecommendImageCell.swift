//
//  TDRecommendImageCell.swift
//  edX
//
//  Created by Elite Edu on 2019/4/16.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDRecommendImageCell: UICollectionViewCell {
    
    let screenWidth = UIScreen.main.bounds.size.width
    
    let bgView = UIView()
    let topImage = UIImageView()
    let leftImage = UIImageView()
    let rightImage = UIImageView()
    let titleLabel = UILabel()
    let line = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setViewConstraint()
    }
    
    var model: TDMainSiteStoryModel? {
        didSet {
            titleLabel.text = model?.story_title
            if let array = model?.story_photo, array.count > 0,
                let host = OEXConfig.shared().apiHostURL()?.absoluteString {
                for i in 0..<array.count {
                    switch i {
                    case 0:
                        topImage.sd_setImage(with: URL(string: "\(host)\(array[0])"), placeholderImage: UIImage(named: "main_recomend_5"))
                    case 1:
                        leftImage.sd_setImage(with: URL(string: "\(host)\(array[1])"), placeholderImage: UIImage(named: "main_recomend_6"))
                    default:
                        rightImage.sd_setImage(with: URL(string: "\(host)\(array[2])"), placeholderImage: UIImage(named: "main_recomend_6"))
                    }
                }
            }
        }
    }
    
    func setViewConstraint() {
        bgView.backgroundColor = UIColor.white
        self.contentView.addSubview(bgView)
        
        topImage.layer.masksToBounds = true
        topImage.layer.cornerRadius = 4.0
        topImage.image = UIImage(named: "main_recomend_5")
        bgView.addSubview(topImage)
        
        leftImage.layer.masksToBounds = true
        leftImage.layer.cornerRadius = 4.0
        leftImage.image = UIImage(named: "main_recomend_6")
        bgView.addSubview(leftImage)
        
        rightImage.layer.masksToBounds = true
        rightImage.layer.cornerRadius = 4.0
        rightImage.image = UIImage(named: "main_recomend_6")
        bgView.addSubview(rightImage)
        
        titleLabel.numberOfLines = 2
        titleLabel.textColor = UIColor(hexString: "#2e313c")
        titleLabel.font = UIFont(name: "PingFang-SC-Medium", size: 15.0)
        bgView.addSubview(titleLabel)
        
        line.backgroundColor = UIColor(hexString: "#f5f5f5")
        bgView.addSubview(line)
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(self.contentView)
        }
        
        let topWidth = screenWidth - 24
        topImage.snp.makeConstraints { (make) in
            make.top.equalTo(bgView).offset(0)
            make.left.equalTo(bgView).offset(12)
            make.right.equalTo(bgView).offset(-12)
            make.height.equalTo(topWidth*0.45)
        }
        
        let bottomWidth = (topWidth-8)/2
        leftImage.snp.makeConstraints { (make) in
            make.top.equalTo(topImage.snp.bottom).offset(8)
            make.left.equalTo(topImage)
            make.size.equalTo(CGSize(width: bottomWidth, height: bottomWidth*0.58))
        }
        
        rightImage.snp.makeConstraints { (make) in
            make.top.equalTo(topImage.snp.bottom).offset(8)
            make.right.equalTo(topImage)
            make.size.equalTo(CGSize(width: bottomWidth, height: bottomWidth*0.58))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(leftImage.snp.bottom).offset(3)
            make.left.equalTo(topImage)
            make.right.equalTo(topImage)
            make.bottom.equalTo(bgView).offset(-6)
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
