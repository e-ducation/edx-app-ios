//
//  TDUserMsgViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/7/26.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDUserMsgViewController: UIViewController {

    private var phoneStr: String
    let tableView = UITableView()
    
    typealias Environment =  OEXAnalyticsProvider & OEXConfigProvider & OEXSessionProvider & OEXStylesProvider & OEXRouterProvider & DataManagerProvider & NetworkManagerProvider
    fileprivate let environment: Environment
    
    init(environment: Environment) {
        self.phoneStr = environment.dataManager.userProfileManager.feedForCurrentUser().output.value?.phone ?? ""
        self.environment = environment
        super.init(nibName: nil, bundle :nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "个人信息"
        configView()
    }
    
    func configView() {
        view.backgroundColor = .white
        
        tableView.tableHeaderView = configTableHeaderView()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorColor = UIColor(hexString: "#f5f5f5")
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view);
        }
    }
    
    func configTableHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 140))
        
        let headerImage = UIImageView()
        headerImage.image = UIImage(named: "defalit_person")
        headerImage.layer.masksToBounds = true
        headerImage.layer.cornerRadius = 39.0
        headerView.addSubview(headerImage)
        
        let cameraButton = UIButton()
        cameraButton.setImage(UIImage(named: "camera_image"), for: .normal)
        headerView.addSubview(cameraButton)
        
        headerImage.snp.makeConstraints { (make) in
            make.centerX.equalTo(headerView)
            make.centerY.equalTo(headerView)
            make.size.equalTo(CGSize(width: 78, height: 78))
        }
        
        cameraButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(headerImage)
            make.right.equalTo(headerImage)
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
        
        return headerView
    }
    
    private func reloadProfileChange() {
        let feed = environment.dataManager.userProfileManager.feedForCurrentUser()
        feed.refresh()
        feed.output.listenOnce(self, fireIfAlreadyLoaded: false) { result in
            if let newProf = result.value {
                self.phoneStr = newProf.phone ?? ""
                self.tableView.reloadData()
            }
            else {
                self.view.makeToast(Strings.Profile.unableToGet, duration: 0.8, position: CSToastPositionCenter)
            }
        }
    }
}

extension TDUserMsgViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TDAccountViewCell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "TDAccountViewCell")
        }
        
        cell?.accessoryType = indexPath.row == 0 ? .none : .disclosureIndicator
        cell?.selectionStyle = indexPath.row == 0 ? .none : .default
        
        cell?.textLabel?.textColor = UIColor(hexString: "#2e313c")
        cell?.detailTextLabel?.textColor = UIColor(hexString: "#aab2bd")
        cell?.textLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        cell?.detailTextLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = "用户名"
            cell?.detailTextLabel?.text = "西欧"
        case 1:
            cell?.textLabel?.text = "性别"
            cell?.detailTextLabel?.text = "请选择"
        case 2:
            cell?.textLabel?.text = "出生年份"
            cell?.detailTextLabel?.text = "请选择"
        default:
            cell?.textLabel?.text = "个性签名"
            cell?.detailTextLabel?.text = "请填写"
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            
        }
        else if indexPath.row == 2 {
            
        }
        else if indexPath.row == 3 {
            let inputVc = TDInputMsgViewController()
            self.navigationController?.pushViewController(inputVc, animated: true)
        }
    }
}
