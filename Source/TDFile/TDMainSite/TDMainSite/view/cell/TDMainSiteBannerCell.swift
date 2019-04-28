//
//  TDMainSiteBannerCell.swift
//  edX
//
//  Created by Elite Edu on 2019/4/16.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

protocol MainSiteBannersDelegate: class {
    func mainSiteBannersSelect(index: NSInteger)
}

class TDMainSiteBannerCell: UICollectionViewCell,TDBannerCycleViewDelegate {
    
    let cycleView = TDBannerCycleView(frame: CGRect.zero)
    weak var delegate: MainSiteBannersDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        setViewConstraint()
    }
    
    func dealwithBannerData(bannerArray: Array<TDMainSiteBannerModel>?, loodTime: Int?) {
        if let array = bannerArray, array.count > 0  {
            var imageArray = Array<String>()
            for model in array {
                imageArray.append(model.mobile_image ?? "")
            }
            cycleView.imageURLStringArr = imageArray
        }
        else {
            cycleView.imageURLStringArr = ["main_cycle_image"]
        }
        
        if let timeNum = loodTime {
            cycleView.timeNum = timeNum > 2*1000 ? Double(timeNum/1000) : 2.0 //大于两秒
        }
    }
    
    func setViewConstraint() {
        
        cycleView.delegate = self
        cycleView.mode = .scaleAspectFill
        self.addSubview(cycleView)
        cycleView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: TDBannerCycleViewDelegate
extension TDMainSiteBannerCell {
    func cycleViewDidSelectedItemAtIndex(_ index: NSInteger) {
        delegate?.mainSiteBannersSelect(index: index)
        print("点击了\(index)")
    }
}
