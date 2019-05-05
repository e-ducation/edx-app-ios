//
//  TDMainSiteHeaderView.swift
//  edX
//
//  Created by Elite Edu on 2019/4/17.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDMainSiteHeaderView: UICollectionReusableView {
    
    private let bgView = UIView()
    private let titleLabel = UILabel()
    let moreButton = UIButton()
    
    public var titleStr : String? {
        didSet {
            titleLabel.text = titleStr
        }
    }
    
    public var moreTitle : String? {
        didSet {
            moreButton.setTitle(moreTitle, for: .normal)
        }
    }
    
    public var hasRight: Bool? {
        didSet {
            moreButton.isHidden = !hasRight!
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setViewConstraint()
        
        titleLabel.text = "推荐课程"
        moreButton.setTitle("全部课程", for: .normal)
    }
    
    func setViewConstraint() {
        
        self.backgroundColor = UIColor.white
        self.addSubview(bgView)
        
        titleLabel.textColor = UIColor(hexString: "#333333")
        titleLabel.font = UIFont(name: "PingFang-TC-Medium", size: 18)
        bgView.addSubview(titleLabel)
        
        moreButton.showsTouchWhenHighlighted = true
        moreButton.setImage(UIImage(named: "more_enter_icon"), for: .normal)
        moreButton.titleLabel?.font = UIFont(name: "PingFang-TC-Regular", size: 14)
        moreButton.setTitleColor(UIColor(hexString: "#a2a2a2"), for: .normal)
        moreButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 3)
        moreButton.imageEdgeInsets = UIEdgeInsets(top: 1, left: 65, bottom: -1, right: -65)
        bgView.addSubview(moreButton)
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(12)
            make.top.bottom.equalTo(bgView)
            make.right.equalTo(bgView).offset(-88)
        }
        
        moreButton.snp.makeConstraints { (make) in
            make.right.equalTo(bgView).offset(-12)
            make.bottom.equalTo(bgView).offset(0)
            make.size.equalTo(CGSize(width: 72, height: 62))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
