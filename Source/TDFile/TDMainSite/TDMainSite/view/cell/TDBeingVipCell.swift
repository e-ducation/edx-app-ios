//
//  TDBeingVipCell.swift
//  edX
//
//  Created by Elite Edu on 2019/4/16.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDBeingVipCell: UICollectionViewCell {
    
    let vipImage = UIImageView()
    
    var imageUrl: String? {
        didSet {
            vipImage.sd_setImage(with: URL(string: imageUrl ?? ""), placeholderImage: UIImage(named: "vip_being_image"))
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViewConstraint()
    }
    
    func setViewConstraint() {
        self.backgroundColor = UIColor.white
        
        vipImage.layer.masksToBounds = true
        vipImage.layer.cornerRadius = 4.0
        vipImage.image = UIImage(named: "vip_being_image")
        self.contentView.addSubview(vipImage)
        vipImage.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(12)
            make.right.equalTo(self.contentView).offset(-12)
            make.top.equalTo(self.contentView).offset(18)
            make.bottom.equalTo(self.contentView).offset(-18)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
