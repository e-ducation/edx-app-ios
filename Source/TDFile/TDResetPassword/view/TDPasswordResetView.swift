//
//  TDPasswordResetView.swift
//  edX
//
//  Created by Elite Edu on 2019/3/29.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDPasswordResetView: UIView {

    let titleLabel = UILabel()
    let inputTextFeld = LogistrationTextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        
        self.backgroundColor = UIColor.white
        inputTextFeld.isSecureTextEntry = true
        inputTextFeld.font = UIFont(name: "PingFangSC-Regular", size: 14)
        self.addSubview(titleLabel)
        self.addSubview(inputTextFeld)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(32)
            make.top.equalTo(self).offset(8)
            make.height.equalTo(25)
        }
        
        inputTextFeld.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.right.equalTo(self).offset(-32)
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(41)
        }
    }
}
