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
    let headerImage = ProfileImageView()
    let cameraButton = UIButton()
    let pickerView = TDSelectSexView()
    
    var imagePicker: ProfilePictureTaker?
    var profile: UserProfile
    typealias Environment =  OEXAnalyticsProvider & OEXConfigProvider & OEXSessionProvider & OEXStylesProvider & OEXRouterProvider & DataManagerProvider & NetworkManagerProvider
    fileprivate let environment: Environment
    
    init(profile: UserProfile, environment: Environment) {
        self.phoneStr = environment.dataManager.userProfileManager.feedForCurrentUser().output.value?.phone ?? ""
        self.environment = environment
        self.profile = profile
        super.init(nibName: nil, bundle :nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Strings.presonalInfo
        configView()
        headerImage.remoteImage = profile.image(networkManager: environment.networkManager)
    }
    
    func configView() {
        view.backgroundColor = .white
        
        tableView.tableHeaderView = configTableHeaderView()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorColor = UIColor(hexString: "#EEEEEE")
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view);
        }
        
        pickerView.isHidden = true
        pickerView.delegate = self
        self.view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view)
        }
    }
    
    func configTableHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 140))
        headerView.addSubview(headerImage)
        
        cameraButton.setImage(UIImage(named: "camera_image"), for: .normal)
        cameraButton.oex_addAction({ [weak self](_) in
            self?.changeUserHeaderImage()
        }, for: .touchUpInside)
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
    
    func changeUserHeaderImage() {
        if profile.parentalConsent ?? false {
            self.view.makeToast(Strings.yearChoose, duration: 0.8, position: CSToastPositionCenter)
            return
        }
        self.imagePicker = ProfilePictureTaker(delegate: self)
        self.imagePicker?.start(alreadyHasImage: self.profile.hasProfileImage)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension TDUserMsgViewController : ProfilePictureTakerDelegate {
    
    func showImagePickerController(picker: UIImagePickerController) {
        self.present(picker, animated: true, completion: nil)
    }
    
    func showChooserAlert(alert: UIAlertController) {
        alert.configurePresentationController(withSourceView: self.cameraButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteImage() {
        let endBlurimate = headerImage.blurimate()
        
        let networkRequest = ProfileAPI.deleteProfilePhotoRequest(username: profile.username!)
        environment.networkManager.taskForRequest(networkRequest) { result in
            if let _ = result.error {
                endBlurimate.remove()
                self.view.makeToast(Strings.Profile.unableToRemovePhoto, duration: 0.8, position: CSToastPositionCenter)
            }
            else {
                //Was sucessful upload
                self.reloadProfileFromImageChange(completionRemovable: endBlurimate)
            }
        }
    }
    
    func imagePicked(image: UIImage, picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        
        let resizedImage = image.resizedTo(size: CGSize(width: 500, height: 500))
        
        var quality: CGFloat = 1.0
        var data = resizedImage.jpegData(compressionQuality: quality)!
        while data.count > MiB && quality > 0 {
            quality -= 0.1
            data = resizedImage.jpegData(compressionQuality: quality)!
        }
        
        headerImage.image = image
        let endBlurimate = headerImage.blurimate()
        
        let networkRequest = ProfileAPI.uploadProfilePhotoRequest(username: profile.username!, imageData: data as NSData)
        environment.networkManager.taskForRequest(networkRequest) { result in
            let anaylticsSource = picker.sourceType == .camera ? AnaylticsPhotoSource.Camera : AnaylticsPhotoSource.PhotoLibrary
            OEXAnalytics.shared().trackSetProfilePhoto(photoSource: anaylticsSource)
            if let _ = result.error {
                endBlurimate.remove()
                self.view.makeToast(Strings.Profile.unableToSetPhoto, duration: 0.8, position: CSToastPositionCenter)
            }
            else {
                //Was successful delete
                self.reloadProfileFromImageChange(completionRemovable: endBlurimate)
            }
        }
    }
    
    func cancelPicker(picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func reloadProfileFromImageChange(completionRemovable: Removable) {
        let feed = self.environment.dataManager.userProfileManager.feedForCurrentUser()
        feed.refresh()
        feed.output.listenOnce(self, fireIfAlreadyLoaded: false) { result in
            completionRemovable.remove()
            if let newProf = result.value {
                self.profile = newProf
                self.tableView.reloadData()
                self.headerImage.remoteImage = newProf.image(networkManager: self.environment.networkManager)
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
            cell?.textLabel?.text = Strings.usernameText
            cell?.detailTextLabel?.text = profile.username
        case 1:
            cell?.textLabel?.text = Strings.chooseSex
            var str = Strings.selectText
            if let gender = profile.gender {
                if  gender == "m" {
                    str = Strings.maleText
                }
                else if gender == "f" {
                    str = Strings.femaleText
                }
                else {
                    str = Strings.noProvide
                }
            }
            cell?.detailTextLabel?.text = str
        case 2:
            cell?.textLabel?.text = Strings.birthYear
            if let year = profile.birthYear {
                cell?.detailTextLabel?.text = "\(year)"
            }
            else {
                cell?.detailTextLabel?.text = Strings.selectText
            }
        default:
            cell?.textLabel?.text = Strings.biographyText
            if let bio = profile.bio, bio.count > 0 {
                cell?.detailTextLabel?.text = Strings.viewMode
            }
            else {
                cell?.detailTextLabel?.text = Strings.editText
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            showSexPicker()
        }
        else if indexPath.row == 2 {
            chooseYearVc()
        }
        else if indexPath.row == 3 {
            editeUserBio()
        }
    }
}

extension TDUserMsgViewController: TDSelectSexViewDelegate {
    func showSexPicker() {
        pickerView.isHidden = false
        pickerView.showSheetViewAnimate(sex: self.profile.gender)
    }
    
    //MARK: TDSelectSexViewDelegate
    func selectButtonClickSex(sex: String?) {
        pickerView.isHidden = true
        if profile.gender != sex {
            self.profile.updateDictionary["gender"] = sex as AnyObject
            self.profile.gender = sex
            updateProfile()
        }
    }
    
    func cancelChooseUserSex() {
        pickerView.isHidden = true
    }
    
    //MARK: 个性签名
    func editeUserBio() {
        let textController = TDInputMsgViewController()
        textController.originText = profile.bio
        textController.doneEditing = { value in
            if value != self.profile.bio {
                self.profile.updateDictionary["bio"] = value as AnyObject
            }
            self.profile.bio = value
            self.updateProfile()
            //            print(value)
        }
        self.navigationController?.pushViewController(textController, animated: true)
    }
    
    //MARK: 年龄
    func chooseYearVc() {
        let selectionController = JSONFormViewController<String>()
        var tableData = [ChooserDatum<String>]()
        let range = 1900...2019
        let titles = range.map { String($0)} .reversed()
        tableData = titles.map { ChooserDatum(value: $0, title: $0, attributedTitle: nil) }
        
        //        tableData.insert(ChooserDatum(value: "--", title: "保密", attributedTitle: nil), at: 0)
        
        var defaultRow = 0
        if let alreadySetValue = profile.birthYear.flatMap({ String($0) }) {
            defaultRow = tableData.index { equalsCaseInsensitive(lhs: $0.value, alreadySetValue) } ?? defaultRow
        }
        
        let dataSource = ChooserDataSource(data: tableData)
        dataSource.selectedIndex = defaultRow
        
        selectionController.dataSource = dataSource
        selectionController.title = Strings.birthYear
        
        selectionController.doneChoosing = { value in
            self.profileValue(value: value)
            //            print("---->>>",value, self.profile.birthYear)
        }
        self.navigationController?.pushViewController(selectionController, animated: true)
    }
    
    func profileValue(value: String?) {
        let newValue = value.flatMap { Int($0) }
        if newValue != profile.birthYear {
            profile.updateDictionary["year_of_birth"] = newValue as AnyObject?
        }
        profile.birthYear = newValue
        
        updateProfile()
    }
    
    private func updateProfile() {
        if profile.hasUpdates {
            environment.dataManager.userProfileManager.updateCurrentUserProfile(profile: profile) {[weak self] result in
                if let newProf = result.value {
                    self?.profile = newProf
                    self?.tableView.reloadData()
                    //13岁前无头像
                    self?.headerImage.remoteImage = newProf.image(networkManager: (self?.environment.networkManager)!)
                }
                else {
                    let message = Strings.Profile.unableToSend
                    self?.view.makeToast(message, duration: 0.8, position: CSToastPositionCenter)
                }
            }
        }
    }
    private func equalsCaseInsensitive(lhs: String, _ rhs: String) -> Bool {
        return lhs.caseInsensitiveCompare(rhs) == .orderedSame
    }
    
}
