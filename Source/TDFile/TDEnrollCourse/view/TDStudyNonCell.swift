//
//  TDStudyNonCell.swift
//  edX
//
//  Created by Elite Edu on 2019/7/19.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDStudyNonCell: UITableViewCell {

    static let cellIdentifier = "TDStudyNonCell"
    
    let bgView = UIView()
    let nonImageview = UIImageView()
    let messageLabel = UILabel()
    let findButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configView()
        setViewConstraint()
    }
    
    var messageStr: String? {
        didSet {
            messageLabel.text = messageStr
        }
    }
    
    var iconStr: String? {
        didSet {
            nonImageview.image = UIImage(named: iconStr ?? "course_non_image")
        }
    }
    
    var hiddenButton: Bool? {
        didSet {
            findButton.isHidden = hiddenButton ?? false
        }
    }
    
    var buttonStr: String? {
        didSet {
            findButton.setTitle(buttonStr ?? "刷新", for: .normal)
        }
    }
    
    
    func configView() {
        self.selectionStyle = .none
        
        bgView.backgroundColor = UIColor.white
        
        nonImageview.contentMode = .scaleAspectFit
        nonImageview.image = UIImage(named: "course_non_image")
        
        messageLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        messageLabel.textColor = UIColor(hexString: "#aab2bd")
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 2
        
        
        findButton.setTitleColor(.white, for: .normal)
        findButton.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        findButton.backgroundColor = UIColor(hexString: "#4788c7")
        findButton.layer.masksToBounds = true
        findButton.layer.cornerRadius = 4.0
        
        self.addSubview(bgView)
        bgView.addSubview(nonImageview)
        bgView.addSubview(messageLabel)
        bgView.addSubview(findButton)
    }
    
    func setViewConstraint() {
      
        bgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self)
        }
        
        findButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(bgView)
            make.bottom.equalTo(bgView).offset(-8)
            make.size.equalTo(CGSize(width: 130, height: 38))
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(28)
            make.right.equalTo(bgView).offset(-28)
            make.bottom.equalTo(findButton.snp.top).offset(-11)
            make.height.equalTo(40)
        }
        
        nonImageview.snp.makeConstraints { (make) in
            make.centerX.equalTo(bgView)
            make.bottom.equalTo(messageLabel.snp.top).offset(-23)
        }
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
