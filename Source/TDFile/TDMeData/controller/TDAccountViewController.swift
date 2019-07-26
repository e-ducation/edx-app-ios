//
//  TDAccountViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/7/25.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDAccountViewController: UIViewController {

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

        title = "账号管理"
        configView()
    }
    
    func configView() {
        
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(hexString: "#f5f5f5")
        tableView.separatorColor = UIColor(hexString: "#f5f5f5")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view);
        }
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

extension TDAccountViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TDAccountViewCell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "TDAccountViewCell")
        }
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.textColor = UIColor(hexString: "#2e313c")
        cell?.detailTextLabel?.textColor = UIColor(hexString: "#ccd1d9")
        cell?.textLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        cell?.detailTextLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = "绑定手机"
            cell?.detailTextLabel?.text = self.phoneStr.count > 0 ? self.phoneStr : "未绑定"
        default:
            cell?.textLabel?.text = "重置密码"
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "f5f5f5")
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let bindPhoneVC = TDBindPhoneViewController()
            bindPhoneVC.bindingPhoneSuccess = { [weak self] in
                self?.reloadProfileChange()
            }
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(bindPhoneVC, animated: true)
        default:
            let vipPackageVc = TDPasswordResetViewController()
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vipPackageVc, animated: true)
        }
    }
}
