//
//  TDHavardCell.swift
//  edX
//
//  Created by Elite Edu on 2019/7/17.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDHavardCell: UITableViewCell {

    static let cellIdentifier = "TDHavardCell"
    
    let shadowView = UIView()
    let bgView = UIView()
    let havardImage = UIImageView()
    let companyImage = UIImageView()
    let timeLabel = UILabel()
    let goImage = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configView()
        setViewConstraint()
    }
    
    var dateStr: String? {
        didSet {
            if let date = dateStr {
                timeLabel.text = Strings.dateOfExpiry + date
            }
        }
    }
    
    
    func configView() {
        shadowView.backgroundColor = UIColor.white.withAlphaComponent(0)
        shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView.layer.shadowRadius = 4.0
        
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 4.0
        bgView.layer.backgroundColor = UIColor.white.cgColor
        
        havardImage.image = UIImage(named: "havard_logo")
        companyImage.image = UIImage(named: "exclusive_image")
        goImage.image = UIImage(named: "goto_image")
        
        timeLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        timeLabel.textColor = UIColor(hexString: "#656d78")
        timeLabel.text = Strings.dateOfExpiry
        
        self.addSubview(shadowView)
        shadowView.addSubview(bgView)
        bgView.addSubview(havardImage)
        bgView.addSubview(companyImage)
        bgView.addSubview(timeLabel)
        bgView.addSubview(goImage)
    }
    
    func setViewConstraint() {
        shadowView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(12)
            make.right.equalTo(self).offset(-11)
            make.top.equalTo(self).offset(16)
            make.bottom.equalTo(self).offset(-6)
        }
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(shadowView)
        }
        
        havardImage.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(0)
            make.top.equalTo(bgView).offset(16)
            make.size.equalTo(CGSize(width: 216, height: 76))
        }
        
        companyImage.snp.makeConstraints { (make) in
            make.right.equalTo(bgView)
            make.top.equalTo(bgView).offset(13)
            make.size.equalTo(CGSize(width: 70, height: 26))
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(13)
            make.top.equalTo(havardImage.snp.bottom).offset(14)
        }
        
        goImage.snp.makeConstraints { (make) in
            make.centerY.equalTo(bgView)
            make.right.equalTo(bgView.snp.right).offset(-16)
            make.size.equalTo(CGSize(width: 9, height: 14))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
