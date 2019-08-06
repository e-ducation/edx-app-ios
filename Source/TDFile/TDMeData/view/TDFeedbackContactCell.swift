//
//  TDFeedbackContactCell.swift
//  edX
//
//  Created by Elite Edu on 2019/7/29.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDFeedbackContactCell: UITableViewCell {

    let inputTextField = UITextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setViewConstraint()
    }
    
    func setViewConstraint() {
        selectionStyle = .none
        contentView.backgroundColor = .white
        
        inputTextField.placeholder = Strings.contactText
        inputTextField.font = UIFont(name: "PingFangSC-Regular", size: 16)
        inputTextField.textColor = UIColor(hexString: "#2e313c")
        inputTextField.returnKeyType = .done
        contentView.addSubview(inputTextField)
        
        inputTextField.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
            make.top.bottom.equalTo(contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
