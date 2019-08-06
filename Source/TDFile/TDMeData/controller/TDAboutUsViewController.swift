//
//  TDAboutViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/7/26.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class AboutInfoCell: UITableViewCell {
    
    let logoImage = UIImageView()
    let versionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setViewConstaint()
    }
    
    func setViewConstaint() {
        logoImage.image = UIImage(named: "about_logo")
        contentView.addSubview(logoImage)
        
        versionLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        versionLabel.textColor = UIColor(hexString: "#656d78")
        versionLabel.textAlignment = .center
        versionLabel.text = "V" + Bundle.main.oex_shortVersionString()
        contentView.addSubview(versionLabel)
        
        logoImage.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize(width: 107, height: 107))
        }
        
        versionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(logoImage.snp.bottom).offset(8)
            make.centerX.equalTo(contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TDAboutViewController: UIViewController {

    let tableView = UITableView()
    let copyRightLabel = UILabel()
    let infoStr = "英荔商学院（www.EliteMBA.cn）是广东英荔国际教育科技有限公司旗下的商业管理类互联网课堂。\n\n英荔与国内外商业管理学术界资深的教授和专家联手，精心设计并制作高质量且极具知识价值的体系化在线课程。同时，筛选并引进国外优质教育内容，向学习者提供经英荔团队打造后的本土化版本。\n\n尽己所能地向更多学习者传递知识是教育者们的共同追求。英荔期望为教育者提供更有效的传递途径，增加知识的触及范围。在此，向各位专家、教授发出诚挚的开课邀请，期待创造、引入更多优质的课程资源，让知识在多元的世界产生更多元的价值。"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Strings.abountUsTitle
        configView()
    }
    
    func configView() {
        
        view.backgroundColor = .white
        
        copyRightLabel.font = UIFont(name: "PingFangSC-Regular", size: 12)
        copyRightLabel.textColor = UIColor(hexString: "#aab2bd")
        copyRightLabel.numberOfLines = 3
        copyRightLabel.textAlignment = .center
        copyRightLabel.text = Strings.guangdongRights
        self.view.addSubview(copyRightLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        
        copyRightLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeBottom).offset(-11)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
            make.height.equalTo(55)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view);
            make.left.equalTo(self.view).offset(12)
            make.right.equalTo(self.view).offset(-12)
            make.bottom.equalTo(copyRightLabel.snp.top).offset(-11)
        }
    }
    
}

extension TDAboutViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = AboutInfoCell(style: .default, reuseIdentifier: "AboutInfoCell")
            return cell
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "TDAccountViewCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "TDAccountViewCell")
        }
        cell?.selectionStyle = .none
        cell?.textLabel?.textColor = UIColor(hexString: "#656d78")
        cell?.textLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        cell?.textLabel?.numberOfLines = 0
        
        cell?.textLabel?.text = infoStr
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 163
        }
        return textHeight(text: infoStr) + 28.0
    }
    
    func textHeight(text: String) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 55, height: 0))
        label.numberOfLines = 0
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
}
