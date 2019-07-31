//
//  TDPasswordResetView.swift
//  edX
//
//  Created by Elite Edu on 2019/3/29.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDPasswordResetView: UIView {

    let line = UILabel()
    let inputTextFeld = UITextField()
    
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
        inputTextFeld.font = UIFont(name: "PingFangSC-Regular", size: 16)
        inputTextFeld.textColor = UIColor(hexString: "#2e313c")
        self.addSubview(inputTextFeld)
        
        line.backgroundColor = UIColor(hexString: "#eff2f6")
        self.addSubview(line)
        
        line.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(1.0)
        }
        
        inputTextFeld.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.bottom.equalTo(line.snp.top)
        }
    }
}
