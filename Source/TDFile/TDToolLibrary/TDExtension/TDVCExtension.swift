//
//  TDVCExtension.swift
//  edX
//
//  Created by Elite Edu on 2019/7/25.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit


extension UIViewController: UIGestureRecognizerDelegate {
    
    func hideNavgationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        //设置statusbar地变颜色
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = .white
    }
}
