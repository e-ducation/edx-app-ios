//
//  TDBannerCycleCell.swift
//  edX
//
//  Created by Elite Edu on 2019/4/23.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDBannerCycleCell: UICollectionViewCell {
    
    var mode : contentMode? {
        didSet{
            switch mode ?? .scaleAspectFill {
            case .scaleAspectFill:
                imageView.contentMode = .scaleAspectFill
            case .scaleAspectFit:
                imageView.contentMode = .scaleAspectFit
            }
        }
    }
    
    //FIXME: 本地和网络下载走的不同路径
    var imageURLString : String? {
        didSet{
            if (imageURLString?.hasPrefix("http"))! { //网络图片:使用SDWebImage下载即可
                imageView.sd_setImage(with: URL(string: imageURLString ?? ""), placeholderImage: UIImage(named: "main_cycle_image"))
            }
            else { //本地图片
                imageView.image = UIImage(named: imageURLString!)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUpUI() {
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.top.equalTo(contentView).offset(12)
            make.right.bottom.equalTo(contentView).offset(-12)
        }
    }
    
    //MARK: 懒加载
    lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4.0
        
        return imageView
    }()
}


