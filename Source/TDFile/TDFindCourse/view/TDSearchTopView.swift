//
//  TDSearchTopView.swift
//  edX
//
//  Created by Elite Edu on 2019/7/19.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDSearchTopView: UIView {

    let bgView = UIView()
    let inputTextField = UITextField()
    let cancelButton = UIButton()
    let deleteButton = UIButton()
    let line = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureViews() {
        
        bgView.backgroundColor = UIColor.white
        self.addSubview(bgView)
        
        inputTextField.placeholder = "请输入"
        inputTextField.font = UIFont(name: "PingFangSC-Regular", size: 18)
        inputTextField.textColor = UIColor(hexString:"#2e313c")
        bgView.addSubview(inputTextField)
        
        cancelButton.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
        cancelButton.setTitleColor(UIColor(hexString: "#2e313c"), for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        bgView.addSubview(cancelButton)
        
        deleteButton.setImage(UIImage(named: "close_circle"), for: .normal)
        deleteButton.oex_addAction({ [weak self](action) in
            self?.inputTextField.text = ""
        }, for: .touchUpInside)
        bgView.addSubview(deleteButton)
        
        line.backgroundColor = UIColor(hexString: "#f5f5f5")
        bgView.addSubview(line)
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(bgView)
            make.right.equalTo(bgView).offset(-12)
            make.size.equalTo(CGSize(width: 48, height: 39))
        }
        
        deleteButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(bgView)
            make.right.equalTo(cancelButton.snp.left)
            make.size.equalTo(CGSize(width: 48, height: 39))
        }
        
        inputTextField.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(12)
            make.centerY.equalTo(bgView)
            make.right.equalTo(deleteButton.snp.left).offset(-3)
            make.height.equalTo(39)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(bgView)
            make.height.equalTo(0.5)
        }
    }
}
