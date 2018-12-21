//
//  TDVipExpiredView.swift
//  edX
//
//  Created by Elite Edu on 2018/12/12.
//  Copyright © 2018年 edX. All rights reserved.
//

import UIKit

class TDVipExpiredView: UIView {

    let bgView = UIView()
    let expiredButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureViews() {
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.addSubview(bgView)
        
        expiredButton.setTitle(Strings.renewVipMembership, for: .normal)
        expiredButton.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        expiredButton.backgroundColor = UIColor.init(hexString: "#06a5ff")
        expiredButton.layer.cornerRadius = 17.0
        bgView.addSubview(expiredButton)
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self)
        }
        
        expiredButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(bgView.snp.centerX)
            make.centerY.equalTo(bgView.snp.centerY)
            make.height.equalTo(34.0)
            make.width.equalTo(179.0)
        }
    }
}
