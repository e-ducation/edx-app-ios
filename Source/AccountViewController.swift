//
//  AccountViewController.swift
//  edX
//
//  Created by Salman on 15/08/2017.
//  Copyright © 2017 edX. All rights reserved.
//

import UIKit
import MessageUI

fileprivate enum AccountviewOptions : Int {
    case BindPhone,
         ResetPassWord,
         SubmitFeedback
    
        static let accountOptions = [BindPhone, ResetPassWord, SubmitFeedback]//Profile, UserSettings, Logout
}

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let contentView = UIView()
    private let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
    private let versionLabel = UILabel()

    typealias Environment =  OEXAnalyticsProvider & OEXConfigProvider & OEXSessionProvider & OEXStylesProvider & OEXRouterProvider & DataManagerProvider & NetworkManagerProvider
    fileprivate let environment: Environment

    private var phoneStr: String
    private var vipStatus: Int
    private var vipRemainDays: Int
    
    init(phoneStr: String, environment: Environment) {
        self.phoneStr = phoneStr
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

        navigationItem.title = Strings.userAccount
        view.backgroundColor = UIColor.init(hexString: "#f5f5f5")
        view.addSubview(contentView)
        contentView.addSubview(tableView)
        contentView.addSubview(versionLabel)

        configureViews()
        addCloseButton()
    }
    
    func configureViews() {
        tableView.estimatedRowHeight = 46.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableView.backgroundColor = UIColor.init(hexString: "#f5f5f5")
        tableView.separatorColor = UIColor(hexString: "#bfc1c9")
        tableView.separatorColor = UIColor(hexString: "#e6e9ed")
        tableView.register(AccountViewCell.self, forCellReuseIdentifier: AccountViewCell.identifier)
        let textStyle = OEXMutableTextStyle(weight: .normal, size: .base, color : OEXStyles.shared().neutralBase())
        textStyle.alignment = NSTextAlignment.center
        versionLabel.attributedText = textStyle.attributedString(withText: Strings.versionDisplay(number: Bundle.main.oex_shortVersionString(), environment: ""))
        versionLabel.accessibilityIdentifier = "AccountViewController:version-label"
        tableView.accessibilityIdentifier = "AccountViewController:table-view"
        addConstraints()
    }

    private func addCloseButton() {
        if (isModal()) { //isModal check if the view is presented then add close button
            let closeButton = UIBarButtonItem(image: UIImage(named: "ic_cancel"), style: .plain, target: nil, action:nil)//UIBarButtonItem(title: Strings.close, style: .plain, target: nil, action: nil)
            closeButton.accessibilityLabel = Strings.Accessibility.closeLabel
            closeButton.accessibilityHint = Strings.Accessibility.closeHint
            closeButton.accessibilityIdentifier = "AccountViewController:close-button"
            navigationItem.rightBarButtonItem = closeButton
            
            closeButton.oex_setAction { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func addConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(safeEdges)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.leading.equalTo(contentView)
            make.trailing.equalTo(contentView)
            make.bottom.equalTo(versionLabel.snp.top)
        }
        
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.leading.equalTo(contentView)
            make.trailing.equalTo(contentView)
            make.bottom.equalTo(contentView).inset(20)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return AccountviewOptions.accountOptions.count
        default:
            return 1
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountViewCell.identifier, for: indexPath) as! AccountViewCell
        cell.separatorInset = UIEdgeInsets.zero
        cell.accessoryType = .disclosureIndicator//accessoryType(option: AccountviewOptions.accountOptions[indexPath.row])
        switch indexPath.section {
        case 0:
            cell.title = Strings.membership
            cell.imageStr = "menbership_image"
            switch self.vipStatus {
            case 1:
                cell.mesage = Strings.noPurchased
            case 2:
                cell.mesage = Strings.vipDays(number: self.vipRemainDays)
            default:
                cell.mesage = Strings.expiredText
            }
        case 1:
            cell.title = optionTitle(option: AccountviewOptions.accountOptions[indexPath.row])
            cell.imageStr = optionImage(option: AccountviewOptions.accountOptions[indexPath.row])
            if indexPath.row == 0 {
                cell.mesage = self.phoneStr.isEmpty ? Strings.noLinked : self.phoneStr
            }
        default:
            cell.title = Strings.settings
            cell.imageStr = "setting_image"
        }
        cell.accessibilityIdentifier = "AccountViewController:table-cell"
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 0:
            let vipPackageVc = TDVipPackageViewController()
            vipPackageVc.vipBuySuccessHandle = { [weak self] in
                self?.reloadProfileChange(type: 0)
            }
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vipPackageVc, animated: true)
        case 1:
            if let option = AccountviewOptions(rawValue: indexPath.row) {
                switch option {
                case .BindPhone:
                    let bindPhoneVC = TDBindPhoneViewController()
                    bindPhoneVC.bindingPhoneSuccess = { [weak self] in
                        self?.reloadProfileChange(type: 1)
                    }
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                    self.navigationController?.pushViewController(bindPhoneVC, animated: true)
                case .ResetPassWord:
                    let vipPackageVc = TDPasswordResetViewController()
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                    self.navigationController?.pushViewController(vipPackageVc, animated: true)
                case .SubmitFeedback:
                    launchEmailComposer()
                }
            }
        default:
            environment.router?.showMySettings(controller: self,logoutHandle:{
                self.logoutAction()
            })
        }

            //            case .Logout:
            //
            //            case .UserSettings:
            //                environment.router?.showMySettings(controller: self)
            //            case .Profile:
            //                guard environment.config.profilesEnabled, let currentUserName = environment.session.currentUser?.username  else { break }
            //                environment.router?.showProfileForUsername(controller: self, username: currentUserName, editable: true)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        if (indexPath.row == AccountviewOptions.Profile.rawValue && !environment.config.profilesEnabled)  {
//            return 0
//        }
        
        return tableView.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "f5f5f5")
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "f5f5f5")
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
//    private func accessoryType(option: AccountviewOptions) -> UITableViewCell.AccessoryType{
//        switch option {
//        case .SubmitFeedback, .Logout:
//            return .none
//
//        default:
//            return .disclosureIndicator
//        }
//    }
    
    private func logoutAction() {
        OEXFileUtility.nukeUserPIIData()
        dismiss(animated: true, completion: { [weak self] in
            
            let username = self?.environment.session.currentUser?.username ?? ""
            UserDefaults.standard.setValue("", forKey: "bindPhone_alertView_\(username)")
            UserDefaults.standard.setValue("", forKey: "hmm_days_\(username)")
            self?.environment.router?.logout()
        })
    }
    
    private func optionImage(option: AccountviewOptions) -> String? {
        switch option {
        case .BindPhone:
            return "phone_image"
        case .ResetPassWord:
            return "password_image"
        default:
            return "feek_back"
        }
    }
    
    private func optionTitle(option: AccountviewOptions) -> String? {
        switch option {
        case .BindPhone:
            return Strings.phoneNumber
        case .ResetPassWord:
            return Strings.passwordResetTitle
        case .SubmitFeedback:
            return Strings.SubmitFeedback.optionTitle
        }

        //        case .UserSettings :
        //            return Strings.settings
        //        case .Profile:
        //            guard environment.config.profilesEnabled else { break }
        //            return Strings.UserAccount.profile
        //        case .Logout:
        //            return Strings.logout
        
//        return nil
    }
    
    private func reloadProfileChange(type:Int) {
        let feed = environment.dataManager.userProfileManager.feedForCurrentUser()
        feed.refresh()
        feed.output.listenOnce(self, fireIfAlreadyLoaded: false) { result in
            if let newProf = result.value {
                if type == 0 {
                    self.vipStatus = newProf.vip_status ?? 1
                    self.vipRemainDays = newProf.vip_remain_days ?? 0
                }
                else {
                    self.phoneStr = newProf.phone ?? ""
                }
                self.tableView.reloadData()
            }
            else {
                self.view.makeToast(Strings.Profile.unableToGet, duration: 0.8, position: CSToastPositionCenter)
            }
        }
    }

}

extension AccountViewController : MFMailComposeViewControllerDelegate {
    func launchEmailComposer() {
        if !MFMailComposeViewController.canSendMail() {
            UIAlertController().showAlert(withTitle: Strings.emailAccountNotSetUpTitle, message: Strings.emailAccountNotSetUpMessage, onViewController: self)
        } else {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.navigationBar.tintColor = OEXStyles.shared().navigationItemTintColor()
            mail.setSubject(Strings.SubmitFeedback.messageSubject)
            
            mail.setMessageBody(EmailTemplates.supportEmailMessageTemplate(), isHTML: false)
            if let fbAddress = environment.config.feedbackEmailAddress() {
                mail.setToRecipients([fbAddress])
            }
            present(mail, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        dismiss(animated: true, completion: nil)
        dismiss(animated: true) {
            if result == MFMailComposeResult.sent {
                self.view.makeToast(Strings.addEmailSuccess, duration: 0.8, position: CSToastPositionCenter)
            }
            else if result == MFMailComposeResult.saved {
                self.view.makeToast(Strings.emailSaved, duration: 0.8, position: CSToastPositionCenter)
            }
            else if result == MFMailComposeResult.cancelled {
                self.view.makeToast(Strings.emailCencel, duration: 0.8, position: CSToastPositionCenter)
            }
            else {
                self.view.makeToast(Strings.emailFailed, duration: 0.8, position: CSToastPositionCenter)
            }
        }
    }
}
