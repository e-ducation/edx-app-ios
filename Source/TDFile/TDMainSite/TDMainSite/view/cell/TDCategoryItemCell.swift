//
//  TDCategoryItemCell.swift
//  edX
//
//  Created by Elite Edu on 2019/4/17.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDCategoryItemCell: UICollectionViewCell {
    
    let bgView = UIView()
    
    let categoryImage = UIImageView()
    let titleLabel = UILabel()
    
    var model: TDMainSiteCategoryModel? {
        didSet {
            titleLabel.text = model?.categories_name
            categoryImage.sd_setImage(with: URL(string: model?.img_for_app ?? ""), placeholderImage: UIImage(named: "main_category_image"))
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setViewConstraint()
        titleLabel.text = "课程分类"
    }
    
    func setViewConstraint() {
        
        self.backgroundColor = UIColor.white
        
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor(hexString: "#f5f5f5").withAlphaComponent(0.3).cgColor
        self.layer.borderWidth = 1.0
        
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 2, height: 4)
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        
        bgView.backgroundColor = UIColor.white
        self.contentView.addSubview(bgView)
        
        categoryImage.contentMode = .scaleAspectFit
        categoryImage.image = UIImage(named: "main_category_image")
        bgView.addSubview(categoryImage)
        
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(hexString: "#666666")
        titleLabel.font = UIFont(name: "PingFang-TC-Regular", size: 14.0)
        bgView.addSubview(titleLabel)
        
        bgView.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(self)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(2)
            make.right.equalTo(bgView).offset(-2)
            make.bottom.equalTo(bgView).offset(-3)
            make.height.equalTo(35)
        }
        
        categoryImage.snp.makeConstraints { (make) in
            make.centerX.equalTo(bgView)
            make.left.greaterThanOrEqualTo(bgView.snp.left).offset(3)
            make.top.greaterThanOrEqualTo(bgView.snp.top).offset(3)
            make.right.lessThanOrEqualTo(bgView.snp.right).offset(-3)
            make.bottom.lessThanOrEqualTo(titleLabel.snp.top).offset(-3)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
