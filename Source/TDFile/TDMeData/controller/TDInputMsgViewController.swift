//
//  TDInputMsgViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/7/26.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDInputMsgViewController: UIViewController {
    
    let bgView = UIView()
    let inputTextView = UITextView()
    let numLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "个性签名"
        
        configView()
        setViewConstraint()
    }
    
    lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.font = UIFont(name: "PingFangSC-Regular", size: 16)
        placeholderLabel.textColor = UIColor(hexString: "#aab2bd")
        placeholderLabel.text = "请输入内容..."
        placeholderLabel.sizeToFit()
        return placeholderLabel
    }()
    
    
    func configView() {
        view.backgroundColor = UIColor(hexString: "#f5f5f5")
        bgView.backgroundColor = .white
        view.addSubview(bgView)
        
        inputTextView.font = UIFont(name: "PingFangSC-Regular", size: 16)
        inputTextView.textColor = UIColor(hexString: "#2e313c")
        bgView.addSubview(inputTextView)
        
        //kvc设置textview的placeholder
        inputTextView.setValue(placeholderLabel, forKey: "_placeholderLabel")
        inputTextView.addSubview(placeholderLabel)
        
        numLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        numLabel.textColor = UIColor(hexString: "#aab2bd")
        numLabel.text = "0/200"
        bgView.addSubview(numLabel)
        
        
    }
    
    func setViewConstraint() {
        bgView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(view).offset(10)
            make.height.equalTo(150)
        }
        
        inputTextView.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(8)
            make.right.equalTo(bgView).offset(-8)
            make.top.bottom.equalTo(bgView)
        }
        
        numLabel.snp.makeConstraints { (make) in
            make.right.equalTo(bgView).offset(-8)
            make.bottom.equalTo(bgView).offset(-8)
        }
    }

}
