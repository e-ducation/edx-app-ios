//
//  TDFeedbackInputCell.swift
//  edX
//
//  Created by Elite Edu on 2019/7/29.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

protocol TDFeedbackInputDelegate: class {
    func feedbackInputText(inputText: String)
    func feedbackInputDidChange(inputCount: Int)
}

class TDFeedbackInputCell: UITableViewCell {

    let maxCount = 100
    weak var delegate: TDFeedbackInputDelegate?
    
    let inputTextView = UITextView()
    let numLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configView()
        setViewConstraint()
        
    }
    
    lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.font = UIFont(name: "PingFangSC-Regular", size: 16)
        placeholderLabel.textColor = UIColor(hexString: "#aab2bd")
        placeholderLabel.numberOfLines = 0
        placeholderLabel.text = Strings.describeDetail
        placeholderLabel.sizeToFit()
        return placeholderLabel
    }()
    
    func configView() {
        selectionStyle = .none
        contentView.backgroundColor = .white
        
        inputTextView.font = UIFont(name: "PingFangSC-Regular", size: 16)
        inputTextView.textColor = UIColor(hexString: "#2e313c")
        inputTextView.returnKeyType = .done
        inputTextView.becomeFirstResponder()
        inputTextView.delegate = self
        contentView.addSubview(inputTextView)
        
        //kvc设置textview的placeholder
        inputTextView.setValue(placeholderLabel, forKey: "_placeholderLabel")
        inputTextView.addSubview(placeholderLabel)
        
        numLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        numLabel.textColor = UIColor(hexString: "#aab2bd")
        numLabel.text = "0/\(maxCount)"
        contentView.addSubview(numLabel)
    }
    
    func setViewConstraint() {
        inputTextView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(12)
            make.right.equalTo(contentView).offset(-16)
            make.top.equalTo(contentView).offset(10)
            make.bottom.equalTo(-33)
        }
        
        numLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-16)
            make.bottom.equalTo(contentView).offset(-13)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TDFeedbackInputCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.markedTextRange == nil {
            if textView.text.count >= maxCount {//复制粘贴字数处理
                textView.text = String(textView.text.prefix(maxCount))
            }
            numLabel.text = "\(textView.text.count)/\(maxCount)"
            
            self.delegate?.feedbackInputDidChange(inputCount: textView.text.count)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" { //换行
            textView.resignFirstResponder()
            return false
        }
        if text == "" {//删除
            return true
        }
        if range.location >= maxCount {
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.feedbackInputText(inputText: textView.text)
        print("textView:",textView.text)
    }
}

