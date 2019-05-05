//
//  TDCourseSeriesCell.swift
//  edX
//
//  Created by Elite Edu on 2019/4/22.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDCourseSeriesCell: UICollectionViewCell {
    let bgView = UIView()
    
    let courseImage = UIImageView()
    let titleLabel = UILabel()
    
    var model: TDMainSiteCourseModel? {
        didSet {
            titleLabel.text = model?.title
            courseImage.sd_setImage(with: URL(string: model?.image ?? ""), placeholderImage: UIImage(named: "main_recomend_course"))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setViewConstraint()
    }
    
    func setViewConstraint() {
        bgView.backgroundColor = UIColor.white
        self.contentView.addSubview(bgView)
        
        courseImage.layer.masksToBounds = true
        courseImage.layer.cornerRadius = 4.0
        courseImage.image = UIImage(named: "main_recomend_course")
        bgView.addSubview(courseImage)
        
        titleLabel.textColor = UIColor(hexString: "#2e313c")
        titleLabel.font = UIFont(name: "PingFang-SC-Medium", size: 14.0)
        bgView.addSubview(titleLabel)
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(self.contentView)
        }
        
        let screenWidth = UIScreen.main.bounds.size.width
        courseImage.snp.makeConstraints { (make) in
            make.top.equalTo(bgView).offset(0)
            make.left.right.equalTo(bgView)
            make.height.equalTo((screenWidth-24)*0.55*0.49)
        }
        
        titleLabel.backgroundColor = UIColor.white
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(bgView)
            make.top.equalTo(courseImage.snp.bottom).offset(8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
