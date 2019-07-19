//
//  TDSearchCourseView.swift
//  edX
//
//  Created by Elite Edu on 2019/7/19.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDSearchCourseView: UIView {

    let bgView = UIView()
    let searchButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureViews() {
        
        bgView.backgroundColor = UIColor.white
        self.addSubview(bgView)
        
        searchButton.setTitle(Strings.renewVipMembership, for: .normal)
        searchButton.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 12)
        searchButton.backgroundColor = UIColor.init(hexString: "#f7f7f7")
        searchButton.layer.cornerRadius = 15.0
        searchButton.setTitle("搜索课程名称、导师名", for: .normal)
        searchButton.setTitleColor(UIColor(hexString: "#afafaf"), for: .normal)
        searchButton.setImage(UIImage(named: "search_course_image"), for: .normal)
        searchButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        searchButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        bgView.addSubview(searchButton)
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self)
        }
        
        searchButton.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(12)
            make.right.equalTo(bgView).offset(-12)
            make.centerY.equalTo(bgView.snp.centerY)
            make.height.equalTo(30.0)
        }
    }
}
