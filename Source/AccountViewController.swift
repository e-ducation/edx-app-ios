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
    case VipPackage,
         Profile,
         BindPhone,
         UserSettings,
         SubmitFeedback,
         Logout
    
        static let accountOptions = [VipPackage, Profile, BindPhone, UserSettings, SubmitFeedback, Logout]
}

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let contentView = UIView()
    private let tableView = UITableView()
    private let versionLabel = UILabel()
    typealias Environment =  OEXAnalyticsProvider & OEXConfigProvider & OEXSessionProvider & OEXStylesProvider & OEXRouterProvider & DataManagerProvider & NetworkManagerProvider
    fileprivate let environment: Environment
    var phoneStr: String
    
    init(phoneStr: String, environment: Environment) {
        self.phoneStr = phoneStr
        self.environment = environment
        super.init(nibName: nil, bundle :nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Strings.userAccount
        view.backgroundColor = environment.styles.standardBackgroundColor()
        view.addSubview(contentView)
        contentView.addSubview(tableView)
        contentView.addSubview(versionLabel)

        configureViews()
        addCloseButton()
    }
    
    func configureViews() {
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.clear
        tableView.register(AccountViewCell.self, forCellReuseIdentifier: AccountViewCell.identifier)
        let textStyle = OEXMutableTextStyle(weight: .normal, size: .base, color : OEXStyles.shared().neutralBlack())
        textStyle.alignment = NSTextAlignment.center
        versionLabel.attributedText = textStyle.attributedString(withText: Strings.versionDisplay(number: Bundle.main.oex_buildVersionString(), environment: ""))
        versionLabel.accessibilityIdentifier = "AccountViewController:version-label"
        tableView.accessibilityIdentifier = "AccountViewController:table-view"
        addConstraints()
    }

    private func addCloseButton() {
        if (isModal()) { //isModal check if the view is presented then add close button
            let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
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
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountviewOptions.accountOptions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountViewCell.identifier, for: indexPath) as! AccountViewCell
        cell.separatorInset = UIEdgeInsets.zero
        cell.accessoryType = accessoryType(option: AccountviewOptions.accountOptions[indexPath.row])
        cell.title = optionTitle(option: AccountviewOptions.accountOptions[indexPath.row])
        cell.accessibilityIdentifier = "AccountViewController:table-cell"
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let option = AccountviewOptions(rawValue: indexPath.row) {
            switch option {
            case .UserSettings:
                environment.router?.showMySettings(controller: self)
            case .Profile:
                guard environment.config.profilesEnabled, let currentUserName = environment.session.currentUser?.username  else { break }
                environment.router?.showProfileForUsername(controller: self, username: currentUserName, editable: true)
            case .SubmitFeedback:
                launchEmailComposer()
            case .Logout:
                OEXFileUtility.nukeUserPIIData()
                dismiss(animated: true, completion: { [weak self] in
                    
                    let username = self?.environment.session.currentUser?.username ?? ""
                    UserDefaults.standard.setValue("", forKey: "bindPhone_alertView_\(username)")
                    self?.environment.router?.logout()
                })
            case .VipPackage:
                let vipPackageVc = TDVipPackageViewController()
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                self.navigationController?.pushViewController(vipPackageVc, animated: true)
            case .BindPhone:
                let bindPhoneVC = TDBindPhoneViewController()
                bindPhoneVC.bindingPhoneSuccess = { [weak self] _ in
                    self?.reloadProfileFromImageChange()
                }
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                self.navigationController?.pushViewController(bindPhoneVC, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.row == AccountviewOptions.Profile.rawValue && !environment.config.profilesEnabled)  {
            return 0
        }
        
        return tableView.estimatedRowHeight
    }
    
    private func accessoryType(option: AccountviewOptions) -> UITableViewCellAccessoryType{
        switch option {
        case .SubmitFeedback, .Logout:
            return .none
    
        default:
            return .disclosureIndicator
        }
    }
    
    private func optionTitle(option: AccountviewOptions) -> String? {
        switch option {
        case .UserSettings :
            return Strings.settings
        case .Profile:
            guard environment.config.profilesEnabled else { break }
            return Strings.UserAccount.profile
        case .SubmitFeedback:
            return Strings.SubmitFeedback.optionTitle
        case .Logout:
            return Strings.logout
        case .VipPackage:
            return "VIP"
        case .BindPhone:
            if (self.phoneStr.isEmpty) {
                return Strings.unboundCellphone
            }
            else {
                print("手机 \(self.phoneStr)")
                return "\(Strings.boundCellphone)\(self.phoneStr)"
            }
        }
        
        return nil
    }
    
    private func reloadProfileFromImageChange() {
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
        dismiss(animated: true, completion: nil)
    }
}
