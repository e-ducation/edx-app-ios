//
//  TDScanQRView.swift
//  edX
//
//  Created by Elite Edu on 2019/8/1.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDScanQRView: UIView {
    
    let screenWidth = UIScreen.main.bounds.width*0.7
    
    let topView = UIView()
    let bottomView = UIView()
    let leftView = UIView()
    let rightView = UIView()
    let boxImageView = UIImageView()
    let lineImageView = UIImageView()
    let messageLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configView()
        setViewConstraint()
        
        print(lineImageView.bounds)
    }
    
    func startAnimation() {
        
        self.layoutIfNeeded()
        UIView.animate(withDuration: 2.0) {
            self.lineImageView.snp.updateConstraints { (make) in
                make.top.equalTo(self.boxImageView).offset(self.screenWidth)
                make.left.equalTo(self.boxImageView).offset(5)
                make.right.equalTo(self.boxImageView).offset(-5)
                make.height.equalTo(2)
            }
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.layoutIfNeeded()
        }
    }
    
    func stopAllAnimation() {
        self.layer.removeAllAnimations()
    }
    
    func configView() {
        topView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.addSubview(topView)
        
        bottomView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.addSubview(bottomView)
        
        leftView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.addSubview(leftView)
        
        rightView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.addSubview(rightView)
        
        boxImageView.image = UIImage(named: "scan_box")
        self.addSubview(boxImageView)
        
        lineImageView.image = UIImage(named: "scan_line")
        boxImageView.addSubview(lineImageView)
        
        messageLabel.text = "请将二维码对准至框内，即可自动扫描"
        messageLabel.textColor = UIColor(hexString: "#ccd1d9")
        messageLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        self.addSubview(messageLabel)
    }
    
    func setViewConstraint() {
        
        boxImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-64)
            make.size.equalTo(CGSize(width: screenWidth, height: screenWidth))
        }
        
        topView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.bottom.equalTo(boxImageView.snp.top)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.top.equalTo(boxImageView.snp.bottom)
        }
        
        leftView.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(boxImageView.snp.left)
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        rightView.snp.makeConstraints { (make) in
            make.right.equalTo(self)
            make.left.equalTo(boxImageView.snp.right)
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(bottomView.snp.top)
        }

        lineImageView.snp.makeConstraints { (make) in
            make.top.equalTo(boxImageView)
            make.left.equalTo(boxImageView).offset(5)
            make.right.equalTo(boxImageView).offset(-5)
            make.height.equalTo(2)
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(boxImageView.snp.bottom).offset(16)
            make.centerX.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
