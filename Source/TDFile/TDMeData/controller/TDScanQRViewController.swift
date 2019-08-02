//
//  TDScanQRViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/8/1.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDScanQRViewController: UIViewController {

    let scanQRView = TDScanQRView()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "扫码登录"
        self.view.backgroundColor = .black
        setViewConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scanQRView.startAnimation()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        changeNavigationBarColor(isBlack: true)
        UINavigationBar.appearance().barStyle = UIBarStyle.default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changeNavigationBarColor(isBlack: false)
        UINavigationBar.appearance().barStyle = UIBarStyle.black
    }
    
    func setViewConstraint() {
        self.view.addSubview(scanQRView)
        scanQRView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view)
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
