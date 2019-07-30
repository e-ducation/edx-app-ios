//
//  TDFeedbackViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/7/29.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDFeedbackViewController: UIViewController {
    
    let tableView = UITableView()
    let commitButton = UIButton()
    
    var textStr: String = ""
    var imageArray = Array<UIImage>()
    var contactStr: String = ""
    
    var gapHeigt: CGFloat = 0.0
    var duration = 0.0
    
    var imagePicker: ProfilePictureTaker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "意见反馈"
        configView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    deinit {
        print("销毁了",self.view.frame)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func commitButtonAction() {//提交
        self.tableView.endEditing(true)
        
    }
    
    func configView() {
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(hexString: "#f5f5f5")
        tableView.tableFooterView = configTableFooterView()
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view);
        }
    }
    
    func configTableFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 110))
        footerView.backgroundColor = UIColor(hexString: "#f5f5f5")
        
        commitButton.backgroundColor = UIColor(hexString: "#ccd1d9")//#4788c7
        commitButton.layer.masksToBounds = true
        commitButton.layer.cornerRadius = 4.0
        commitButton.setTitle(Strings.submitText, for: .normal)
        commitButton.setTitleColor(.white, for: .normal)
        commitButton.addTarget(self, action: #selector(commitButtonAction), for: .touchUpInside)
        footerView.addSubview(commitButton)
        
        commitButton.snp.makeConstraints { (make) in
            make.left.equalTo(footerView).offset(16)
            make.right.equalTo(footerView).offset(-16)
            make.top.equalTo(footerView).offset(32)
            make.height.equalTo(46)
        }
        
        return footerView
    }
    
}

extension TDFeedbackViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = TDFeedbackInputCell(style: .default, reuseIdentifier: "TDFeedbackInputCell")
            cell.delegate = self
            return cell
        case 1:
            let cell = TDFeedbackImageCell(style: .default, reuseIdentifier: "TDFeedbackImageCell")
            cell.delegate = self
            cell.reloadImageData(imageArray: imageArray)
            return cell
        default:
            let cell = TDFeedbackContactCell(style: .default, reuseIdentifier: "TDFeedbackContactCell")
            cell.inputTextField.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 198
        case 1:
            let screenWidth = UIScreen.main.bounds.size.width - 32 - 33
            return screenWidth/4 + 75
        default:
            return 46
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#f5f5f5")
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.tableView.endEditing(true)
    }
}

extension TDFeedbackViewController: UITextFieldDelegate, TDFeedbackInputDelegate {
    //MARK: TDFeedbackInputDelegate
    func feedbackInputText(inputText: String) {
        textStr = inputText
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("开始: textField")
        showKeyboardMove()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        contactStr = textField.text ?? ""
        hideKeyboardMove()
        print("结束 textField：",textField.text as Any)
    }
    
    @objc func keybordWillShow(notification: Notification) { //键盘弹出
        
        guard gapHeigt == 0 else {
            return
        }
        
        let rect = self.tableView.superview?.convert(self.tableView.frame, to: self.view)
        
        let userInfo: Dictionary = notification.userInfo!
        let avalue: NSValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        var keyboardRect = avalue.cgRectValue
        keyboardRect = self.view.convert(keyboardRect, to: self.view.window)
        
        let keyboardTop = keyboardRect.origin.y
        
        let durationValue: NSNumber = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        duration = durationValue.doubleValue
        
        if keyboardTop < rect!.maxY {
            let move = rect!.maxY - keyboardTop - 110
            gapHeigt = move
        }
    }
    
    func showKeyboardMove() { //键盘弹出页面
        guard gapHeigt > 0.0 else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.view.frame = CGRect(x: 0, y: -self.gapHeigt, width: self.view.bounds.width, height: self.view.bounds.height)
        }
    }
    
    func hideKeyboardMove() { //键盘收回页面
        guard gapHeigt > 0.0 else {
            return
        }
        UIView.animate(withDuration: duration) {
            let navHeight = self.navigationController?.navigationBar.frame.height ?? 0
            let statusHeight = UIApplication.shared.statusBarFrame.height
            self.view.frame = CGRect(x: 0, y: statusHeight + navHeight, width: self.view.bounds.width, height: self.view.bounds.height)
        }
    }
    
    @objc func keybordWillHide(notification: Notification) {
        
        //        let userInfo: Dictionary = notification.userInfo!
        //        let durationValue: NSNumber = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        //        let duration = durationValue.doubleValue
        //
        //        if self.view.frame.origin.y < 0 {
        //            UIView.animate(withDuration: duration) {
        //                let navHeight = self.navigationController?.navigationBar.frame.height ?? 0
        //                let statusHeight = UIApplication.shared.statusBarFrame.height
        //                self.view.frame = CGRect(x: 0, y: statusHeight + navHeight, width: self.view.bounds.width, height: self.view.bounds.height)
        //            }
        //        }
    }
}

extension TDFeedbackViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate, TDFeedbackImageDelegate {
    
    //MARK: TDFeedbackImageDelegate
    func deleteImageForArray(imageArray: Array<UIImage>) {
        self.tableView.endEditing(true)
        self.imageArray = imageArray
    }
    
    func declickImageItem() {
        self.tableView.endEditing(true)
    }
    
    func clickAddImageButton() {
        self.tableView.endEditing(true)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { [weak self](action) in
            self?.showImagePicker(sourceType: .camera)
        }
        let albumAction = UIAlertAction(title: "本地上传", style: .default) { [weak self](action) in
            self?.showImagePicker(sourceType: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
            
        }
        alertController.addAction(cameraAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showImagePicker(sourceType : UIImagePickerController.SourceType) {
        
        let imagePicker = UIImagePickerController()
        let mediaType: String = kUTTypeImage as String
        imagePicker.mediaTypes = [mediaType]
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        
        if sourceType == .camera {
            imagePicker.showsCameraControls = true
            imagePicker.cameraCaptureMode = .photo
            imagePicker.cameraDevice = .front
            imagePicker.cameraFlashMode = .auto
        }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.imageArray.append(image)
                DispatchQueue.main.async {
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
                }
            }
            else {
                fatalError("no image returned from picker")
            }
            print("didFinishPickingMediaWithInfo",info)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        print("imagePickerControllerDidCancel")
    }
}
