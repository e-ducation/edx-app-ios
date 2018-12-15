//
//  TDVipRecomendView.swift
//  edX
//
//  Created by Elite Edu on 2018/12/13.
//  Copyright © 2018年 edX. All rights reserved.
//

import UIKit

class TDVipRecomendView: UIView {

    let bgView = UIView()
    let checkButton = UIButton()
    let recomendLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureViews()
    }
    
    func configureViews() {
        bgView.backgroundColor = UIColor(hexString: "#ddecfa")
        self.addSubview(bgView)
        
        recomendLabel.text = "订阅会员课程 ¥1199/年"
        recomendLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        recomendLabel.textColor = UIColor(hexString: "#346ca3")
        bgView.addSubview(recomendLabel)
        
        checkButton.setTitle("查看详情", for: .normal)
        checkButton.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 14)
        checkButton.layer.cornerRadius = 4.0
        checkButton.layer.borderWidth = 1.0;
        checkButton.layer.borderColor = UIColor(hexString: "#4788c7").cgColor
        checkButton.backgroundColor = UIColor.init(hexString: "#ffffff")
        checkButton.setTitleColor(UIColor(hexString: "#346ca3"), for: .normal)
        bgView.addSubview(checkButton)
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self)
        }
        
        checkButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(bgView.snp.centerY)
            make.right.equalTo(bgView.snp.right).offset(-22)
            make.height.equalTo(38.0)
            make.width.equalTo(95.0)
        }
        
        recomendLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(bgView.snp.centerY)
            make.left.equalTo(bgView.snp.left).offset(22)
            make.right.equalTo(checkButton.snp.left).offset(-6)
        }
    }

}
