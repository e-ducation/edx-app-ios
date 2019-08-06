//
//  TDInputMsgViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/7/26.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDInputMsgViewController: UIViewController {
    
    let maxCount = 200
    var originText: String?
    
    var doneEditing: ((_ value: String)->())?
    
    let bgView = UIView()
    let inputTextView = UITextView()
    let numLabel = UILabel()
    let rightButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.biographyText
        addRightNavItem()
        configView()
        setViewConstraint()
    }
    
    lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.font = UIFont(name: "PingFangSC-Regular", size: 16)
        placeholderLabel.textColor = UIColor(hexString: "#aab2bd")
        placeholderLabel.text = Strings.pleaseEnterText
        placeholderLabel.sizeToFit()
        return placeholderLabel
    }()
    
    func addRightNavItem() {
        
        rightButton.titleLabel?.font = UIFont(name: "PingFang-SC-Regular", size: 16)
        rightButton.setTitle(Strings.ok, for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        dealWithRightButton(text: originText)
        
        rightButton.oex_addAction({ [weak self](_) in
            self?.handinSignature()
            }, for: .touchUpInside)
    }
    
    func handinSignature() {
        doneEditing?(inputTextView.text)
        self.navigationController?.popViewController(animated: true)
    }
    
    func configView() {
        view.backgroundColor = UIColor(hexString: "#f5f5f5")
        bgView.backgroundColor = .white
        view.addSubview(bgView)
        
        inputTextView.font = UIFont(name: "PingFangSC-Regular", size: 16)
        inputTextView.textColor = UIColor(hexString: "#2e313c")
        inputTextView.delegate = self
        bgView.addSubview(inputTextView)
        
        //kvc设置textview的placeholder
        inputTextView.setValue(placeholderLabel, forKey: "_placeholderLabel")
        inputTextView.addSubview(placeholderLabel)
        
        numLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        numLabel.textColor = UIColor(hexString: "#aab2bd")
        numLabel.text = "0/\(maxCount)"
        bgView.addSubview(numLabel)
        
        if originText != nil {
            inputTextView.text = originText
        }
    }
    
    func setViewConstraint() {
        bgView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(view).offset(10)
            make.height.equalTo(150)
        }
        
        numLabel.snp.makeConstraints { (make) in
            make.right.equalTo(bgView).offset(-8)
            make.bottom.equalTo(bgView).offset(-8)
            make.height.equalTo(22)
        }
        
        inputTextView.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(8)
            make.right.equalTo(bgView).offset(-8)
            make.top.equalTo(bgView)
            make.bottom.equalTo(numLabel.snp.top).offset(-6)
        }
    }

}

extension TDInputMsgViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.markedTextRange == nil {
            let count = textView.text.count
            if count >= maxCount {//复制粘贴字数处理
                textView.text = String(textView.text.prefix(maxCount))
            }
            numLabel.text = "\(count)/\(maxCount)"
            dealWithRightButton(text: textView.text)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return false
        }
        if text == "" {
            return true
        }
        if range.location >= maxCount {
            return false
        }
        return true
    }
    
    func dealWithRightButton(text: String?) {
        if let str = text,str.count > 0 {
            rightButton.setTitleColor(UIColor(hexString: "#0f80bf"), for: .normal)
            rightButton.isUserInteractionEnabled = true
        }
        else {
            rightButton.setTitleColor(UIColor(hexString: "#ccd1d9"), for: .normal)
            rightButton.isUserInteractionEnabled = false
        }
    }
}
