//
//  TDVCExtension.swift
//  edX
//
//  Created by Elite Edu on 2019/7/25.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit


extension UIViewController: UIGestureRecognizerDelegate {
    
    //MARK: 隐藏导航栏
    func hideNavgationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
       
        statusBarColor(color: .white)
    }
    
    //MARK: statusbar颜色
    func statusBarColor(color: UIColor) {
        //设置statusbar地变颜色
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }
    
    //MARK: 设置黑色导航栏
    func changeNavigationBarColor(isBlack: Bool) {
        
        navigationController?.navigationBar.barTintColor = isBlack ? .black : .white
        navigationController?.navigationBar.tintColor = isBlack ? .white : .black
        navigationController?.navigationBar.titleTextAttributes = navigationBarStyle(color: isBlack ? .white : .black).attributes.attributedKeyDictionary()
        
        statusBarColor(color: isBlack ? .black : .white)
        
        navigationController?.navigationBar.barStyle = UIBarStyle.black
    }
    
    func navigationBarStyle(color: UIColor) -> OEXTextStyle {
        return OEXTextStyle(weight: .bold, size: .xLarge, color : color)
    }
    
}

