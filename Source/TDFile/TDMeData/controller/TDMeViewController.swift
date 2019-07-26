//
//  TDMeViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/7/25.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDMeViewController: UIViewController {
    
    private let tableView = UITableView()
    
    typealias Environment =  OEXAnalyticsProvider & OEXConfigProvider & OEXSessionProvider & OEXStylesProvider & OEXRouterProvider & DataManagerProvider & NetworkManagerProvider
    fileprivate let environment: Environment
    
    private var vipStatus: Int
    private var vipRemainDays: Int
    
    init(environment: Environment) {
        self.environment = environment
        self.vipStatus = environment.dataManager.userProfileManager.feedForCurrentUser().output.value?.vip_status ?? 1
        self.vipRemainDays = environment.dataManager.userProfileManager.feedForCurrentUser().output.value?.vip_remain_days ?? 0
        super.init(nibName: nil, bundle :nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavgationBar()
    }
    
    func configureViews() {
        
        view.backgroundColor = UIColor.init(hexString: "#f5f5f5")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 55.0
        tableView.backgroundColor = UIColor.init(hexString: "#f5f5f5")
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(view)
        }
    }
    
    private func reloadProfileChange() {
        let feed = environment.dataManager.userProfileManager.feedForCurrentUser()
        feed.refresh()
        feed.output.listenOnce(self, fireIfAlreadyLoaded: false) { result in
            if let newProf = result.value {
                self.vipStatus = newProf.vip_status ?? 1
                self.vipRemainDays = newProf.vip_remain_days ?? 0
                self.tableView.reloadData()
            }
            else {
                self.view.makeToast(Strings.Profile.unableToGet, duration: 0.8, position: CSToastPositionCenter)
            }
        }
    }
    
    private func logoutAction() {
        OEXFileUtility.nukeUserPIIData()
        let username = self.environment.session.currentUser?.username ?? ""
        let bindKey = BIND_PHONE_ALERTVIEW + username
        UserDefaults.standard.setValue("", forKey: bindKey)
        UserDefaults.standard.setValue("", forKey: HARVARD_DAYS + username)
        self.environment.router?.logout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TDMeViewController: UITableViewDelegate,UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 2
        default:
            return 2
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = TDMeDataCell(style: .default, reuseIdentifier: TDMeDataCell.identifier)
            cell.accessoryType = .none
            return cell
        }
        else {
            let cell = AccountViewCell(style: .default, reuseIdentifier: AccountViewCell.identifier)
            cell.accessoryType = .disclosureIndicator
            
            if indexPath.section == 1 {
                switch indexPath.row {
                case 0:
                    cell.imageStr = "me_vip_membership"
                    cell.title = "会员资格"
                    cell.mesage = "未购买"
                case 1:
                    cell.imageStr = "me_account_manager"
                    cell.title = "账号管理"
                default:
                    cell.imageStr = "me_scan_login"
                    cell.title = "扫码登录"
                    
                }
            }
            else if indexPath.section == 2 {
                switch indexPath.row {
                case 0:
                    cell.imageStr = "me_feekback"
                    cell.title = "意见反馈"
                default:
                    cell.imageStr = "me_good_apraise"
                    cell.title = "给我们好评论"
                }
            }
            else {
                switch indexPath.row {
                case 0:
                    cell.imageStr = "me_about_use"
                    cell.title = "关于我们"
                default:
                    cell.imageStr = "me_setting"
                    cell.title = "设置"
                }
            }
            
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 129
        }
        return 55
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "f5f5f5")
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 10.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        if indexPath.section == 0 {
        }
        else {
            if indexPath.section == 1 {
                switch indexPath.row {
                case 0:
                    guard let currentUserName = environment.session.currentUser?.username else { break }
                    let vipPackageVc = TDVipPackageViewController()
                    vipPackageVc.username = currentUserName
                    vipPackageVc.vipBuySuccessHandle = { [weak self] in
                        self?.reloadProfileChange()
                    }
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                    self.navigationController?.pushViewController(vipPackageVc, animated: true)
                case 1:
                    let accountVc = TDAccountViewController(environment: environment)
                    self.navigationController?.pushViewController(accountVc, animated: true)
                default:
                     print("扫码登录")
                }
            }
            else if indexPath.section == 2 {
//                switch indexPath.row {
//                case 0:
//                default:
//                }
            }
            else {
                switch indexPath.row {
                case 0:
                    print("关于我们")
                default:
                    environment.router?.showMySettings(controller: self,logoutHandle:{
                        self.logoutAction()
                    })
                }
            }
        }
    }
}

