//
//  TDFeedbackImageItemCell.swift
//  edX
//
//  Created by Elite Edu on 2019/7/30.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDFeedbackImageItemCell: UICollectionViewCell {
    
    static let identifier = "TDFeedbackImageItemCell"
    let imageView = UIImageView()
    let deleteButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        setViewConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViewConstraint() {
        
        imageView.image = UIImage(named: "feedback_add")
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4.0
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        
        deleteButton.setImage(UIImage(named: "delete_icon"), for: .normal)
        contentView.addSubview(deleteButton)
        
        imageView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(contentView)
        }
        
        deleteButton.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(3)
            make.right.equalTo(contentView).offset(-3)
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
    }
}
