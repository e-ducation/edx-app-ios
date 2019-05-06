//
//  TDMainSiteFooterReusableView.swift
//  edX
//
//  Created by Elite Edu on 2019/4/17.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDMainSiteFooterReusableView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hexString: "#f5f5f5")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
