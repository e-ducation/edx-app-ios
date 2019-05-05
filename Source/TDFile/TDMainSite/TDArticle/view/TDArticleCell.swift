//
//  TDArticleCell.swift
//  edX
//
//  Created by Elite Edu on 2019/4/16.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDArticleCell: UITableViewCell {
    
    private let bgView = UIView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let likeButton = UIButton()
    private let tagLabel = UILabel()
    private let articleImage = UIImageView()
    
    var model : TDArticleModel? {
        didSet {
            titleLabel.text = model?.title
            dateLabel.text = model?.article_datetime
            likeButton.setTitle("\(model?.liked_count ?? 0)", for: .normal)
            articleImage.sd_setImage(with: URL(string: model?.articleImageStr ?? ""), placeholderImage: UIImage(named: "article_box_image"))
            
            guard let array = model?.tags else {
                return
            }
            tagLabel.text = array.joined(separator: " ")
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setViewConstraint()
    }
    
    func setViewConstraint() {
        
        bgView.backgroundColor = UIColor.white
        self.contentView.addSubview(bgView)
        
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor(hexString: "#2e313c")
        titleLabel.font = UIFont(name: "PingFang-SC-Medium", size: 15)
        bgView.addSubview(titleLabel)
        
        dateLabel.textColor = UIColor(hexString: "#bbbbbb")
        dateLabel.font = UIFont(name: "PingFang-SC-Regular", size: 12)
        bgView.addSubview(dateLabel)
        
        likeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: -3)
        likeButton.imageEdgeInsets = UIEdgeInsets(top: -1, left: -3, bottom: 1, right: 3)
        likeButton.titleLabel?.font = UIFont(name: "PingFang-SC-Regular", size: 12)
        likeButton.setImage(UIImage(named: "thumb_up_icon"), for: .normal)
        likeButton.setTitleColor(UIColor(hexString: "#bbbbbb"), for: .normal)
        bgView.addSubview(likeButton)
        
        tagLabel.textAlignment = .right
        tagLabel.textColor = UIColor(hexString: "#bbbbbb")
        tagLabel.font = UIFont(name: "PingFang-SC-Regular", size: 12)
        bgView.addSubview(tagLabel)
        
        articleImage.image = UIImage(named: "article_box_image")
        articleImage.layer.masksToBounds = true
        articleImage.layer.cornerRadius = 4.0
        articleImage.contentMode = .scaleAspectFill
        bgView.addSubview(articleImage)
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.contentView)
        }
        
        articleImage.snp.makeConstraints { (make) in
            make.centerY.equalTo(bgView.snp.centerY)
            make.right.equalTo(bgView.snp.right).offset(-16)
            make.size.equalTo(CGSize(width: 90, height: 90))
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bgView.snp.left).offset(12)
            make.bottom.equalTo(articleImage.snp.bottom)
            make.height.equalTo(18)
            make.width.equalTo(105)
        }
        
        likeButton.snp.makeConstraints { (make) in
            make.left.equalTo(dateLabel.snp.right).offset(3)
            make.bottom.equalTo(dateLabel)
            make.height.equalTo(18)
            make.width.equalTo(58)
        }
        
        tagLabel.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualTo(likeButton.snp.right).offset(3)
            make.bottom.equalTo(dateLabel.snp.bottom)
            make.height.equalTo(18)
            make.right.equalTo(articleImage.snp.left).offset(-8)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bgView.snp.left).offset(12)
            make.right.equalTo(articleImage.snp.left).offset(-8)
            make.top.equalTo(articleImage)
            make.bottom.lessThanOrEqualTo(dateLabel.snp.top).offset(-6)
            
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
