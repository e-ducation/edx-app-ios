//
//  TDAuthorConfirmViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/8/2.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDAuthorConfirmViewController: UIViewController {

    let dismissButton = UIButton()
    let imageView = UIImageView()
    let messageLabel = UILabel()
    let sureButton = UIButton()
    let cancelButton = UIButton()
    
    var popAction: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
        setViewConstraint()
    }
    
    @objc func dismissButtonAction() {
        popAction?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func sureButtonAction() {
        popAction?()
        self.dismiss(animated: true, completion: nil)
    }
    
    func configView() {
        self.view.backgroundColor = .white
        
        dismissButton.setImage(UIImage(named: "down_image"), for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonAction), for: .touchUpInside)
        view.addSubview(dismissButton)
        
        imageView.image = UIImage(named: "author_image")
        view.addSubview(imageView)
        
        messageLabel.text = "英荔商学院网页登陆确认"
        messageLabel.font = UIFont(name: "PingFangSC-Regular", size: 16)
        messageLabel.textColor = UIColor(hexString: "#2e313c")
        view.addSubview(messageLabel)
        
        sureButton.backgroundColor = UIColor(hexString: "#4788c7")
        sureButton.layer.masksToBounds = true
        sureButton.layer.cornerRadius = 4.0
        sureButton.setTitle("确认登陆", for: .normal)
        sureButton.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        sureButton.setTitleColor(.white, for: .normal)
        sureButton.addTarget(self, action: #selector(sureButtonAction), for: .touchUpInside)
        view.addSubview(sureButton)
        
        cancelButton.setTitle("取消登录", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
        cancelButton.setTitleColor(UIColor(hexString: "#aab2bd"), for: .normal)
        cancelButton.addTarget(self, action: #selector(dismissButtonAction), for: .touchUpInside)
        view.addSubview(cancelButton)
    }
    
    func setViewConstraint() {
        dismissButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(12)
            make.top.equalTo(safeTop).offset(8)
            make.size.equalTo(CGSize(width: 33, height: 33))
        }
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.dismissButton.snp.bottom).offset(95)
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(18)
            make.centerX.equalTo(self.view)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(18)
            make.right.equalTo(self.view).offset(-18)
            make.bottom.equalTo(safeBottom).offset(-32)
            make.height.equalTo(46)
        }
        
        sureButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(18)
            make.right.equalTo(self.view).offset(-18)
            make.bottom.equalTo(cancelButton.snp.top).offset(-32)
            make.height.equalTo(46)
        }
    }
    

}
