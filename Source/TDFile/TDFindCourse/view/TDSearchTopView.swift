//
//  TDSearchTopView.swift
//  edX
//
//  Created by Elite Edu on 2019/7/19.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

protocol TDSearchTopViewDelegate: class {
    func clickCancelButton()
    func clickDeleteButton()
    func inputTextFieldValueChange(searchText: String)
}

class TDSearchTopView: UIView {

    let bgView = UIView()
    let inputTextField = UITextField()
    let cancelButton = UIButton()
    let deleteButton = UIButton()
    
    weak var delegate: TDSearchTopViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        buttonClickAction()
    }
    
    func buttonClickAction() {
        cancelButton.oex_addAction({ [weak self](_) in
            self?.inputTextField.resignFirstResponder()
            self?.delegate?.clickCancelButton()
            }, for: .touchUpInside)
        
        deleteButton.oex_addAction({ [weak self](_) in
            self?.inputTextField.text = ""
            self?.delegate?.clickDeleteButton()
            }, for: .touchUpInside)
        
        inputTextField.oex_addAction({ [weak self](_) in
            self?.dealSearchText()
        }, for: .editingChanged)
    }
    
    func dealSearchText() {
        if self.inputTextField.markedTextRange == nil { //确认输入内容后，为nil
            self.delegate?.inputTextFieldValueChange(searchText: self.inputTextField.text ?? "")
        }
        self.deleteButton.isHidden = self.inputTextField.text?.count == 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureViews() {
        
        bgView.backgroundColor = UIColor.white
        self.addSubview(bgView)
        
        inputTextField.placeholder = Strings.pleaseEnter
        inputTextField.font = UIFont(name: "PingFangSC-Regular", size: 16)
        inputTextField.textColor = UIColor(hexString:"#2e313c")
        bgView.addSubview(inputTextField)
        
        cancelButton.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
        cancelButton.setTitleColor(UIColor(hexString: "#2e313c"), for: .normal)
        cancelButton.setTitle(Strings.cancel, for: .normal)
        bgView.addSubview(cancelButton)
        
        deleteButton.setImage(UIImage(named: "close_circle"), for: .normal)
        deleteButton.isHidden = true
        deleteButton.oex_addAction({ [weak self](action) in
            self?.inputTextField.text = ""
        }, for: .touchUpInside)
        bgView.addSubview(deleteButton)
        
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
            make.size.equalTo(CGSize(width: 39, height: 39))
        }
        
        inputTextField.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(0)
            make.centerY.equalTo(bgView)
            make.right.equalTo(deleteButton.snp.left).offset(-3)
            make.height.equalTo(33)
        }
    }
}
