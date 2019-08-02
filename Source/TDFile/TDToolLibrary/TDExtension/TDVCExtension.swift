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
       
        statusBarColor(color: .white)
    }
    
    func statusBarColor(color: UIColor) {
        //设置statusbar地变颜色
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }
    
    func changeNavigationBarColor(isBlack: Bool) {
        
        navigationController?.navigationBar.barTintColor = isBlack ? .black : .white
        navigationController?.navigationBar.tintColor = isBlack ? .white : .black
        navigationController?.navigationBar.titleTextAttributes = navigationBarStyle(color: isBlack ? .white : .black).attributes.attributedKeyDictionary()
        
        statusBarColor(color: isBlack ? .black : .white)
        
//        navigationController?.navigationBar.barStyle = isBlack ? UIBarStyle.default : UIBarStyle.black
        
    }
    
    func navigationBarStyle(color: UIColor) -> OEXTextStyle {
        return OEXTextStyle(weight: .bold, size: .xLarge, color : color)
    }
}
