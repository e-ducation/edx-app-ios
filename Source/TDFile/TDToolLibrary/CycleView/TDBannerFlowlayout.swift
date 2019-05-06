//
//  TDBannerFlowlayout.swift
//  edX
//
//  Created by Elite Edu on 2019/4/23.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDBannerFlowlayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        //尺寸
        itemSize = (collectionView?.bounds.size)!
        //间距
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        //滚动方向
        scrollDirection = .horizontal
    }
}
