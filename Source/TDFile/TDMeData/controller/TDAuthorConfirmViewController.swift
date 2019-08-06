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
    
    var authorUrl: String?
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
        
        guard let url = authorUrl, let host = OEXConfig.shared().apiHostURL()?.absoluteString else {
            return
        }
        
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer.setValue(OEXAuthentication.authHeaderForApiAccess(), forHTTPHeaderField: "Authorization")
        
        let confirmUrl = host + url + "&confirm=true"
        manager.get(confirmUrl, parameters: nil, progress: nil, success: { (task, response) in
            print("扫码接口", response)
            
            let responseDic = response as! Dictionary<String, Any>
            let code: Int = responseDic["code"] as! Int
            self.popView(message: code == 200 ? Strings.scanSuccess : Strings.scanFailed)
            
        }) { (task, error) in
            self.popView(message: Strings.scanFailed)
        }
    }
    
    func popView(message: String) {
        SVProgressHUD.dismiss()
        
        popAction?()
        UIApplication.shared.keyWindow?.rootViewController?.view.makeToast(message, duration: 1.03, position: CSToastPositionCenter)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: UI
    func configView() {
        self.view.backgroundColor = .white
        
        dismissButton.setImage(UIImage(named: "down_image"), for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonAction), for: .touchUpInside)
        view.addSubview(dismissButton)
        
        imageView.image = UIImage(named: "author_image")
        view.addSubview(imageView)
        
        messageLabel.text = Strings.webLogin
        messageLabel.font = UIFont(name: "PingFangSC-Regular", size: 16)
        messageLabel.textColor = UIColor(hexString: "#2e313c")
        view.addSubview(messageLabel)
        
        sureButton.backgroundColor = UIColor(hexString: "#4788c7")
        sureButton.layer.masksToBounds = true
        sureButton.layer.cornerRadius = 4.0
        sureButton.setTitle(Strings.confirmLogin, for: .normal)
        sureButton.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        sureButton.setTitleColor(.white, for: .normal)
        sureButton.addTarget(self, action: #selector(sureButtonAction), for: .touchUpInside)
        view.addSubview(sureButton)
        
        cancelButton.setTitle(Strings.cancelConfirm, for: .normal)
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
        
        let screenHeight = UIScreen.main.bounds.height
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dismissButton.snp.bottom).offset(screenHeight*0.3)
            make.centerX.equalTo(self.view)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.messageLabel.snp.top).offset(-18)
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
