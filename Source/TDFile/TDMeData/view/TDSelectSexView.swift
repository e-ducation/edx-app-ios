//
//  TDSelectSexView.swift
//  edX
//
//  Created by Elite Edu on 2019/8/1.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

protocol TDSelectSexViewDelegate: class {
    func selectButtonClickSex(sex: String?)
    func cancelChooseUserSex()
}

class TDSelectSexView: UIView {

    var sexStr: String?
    weak var delegate: TDSelectSexViewDelegate?
    let sheetHeigt = 228
    
    let topButton = UIButton()
    let sheetView = UIView()
    let cancelButton = UIButton()
    let sureButton = UIButton()
    let pickerView = UIPickerView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configView()
        setViewConstraint()
    }
    
    @objc func cancelButtonAction() {
        hideSheetViewAnimate(isSure: false)
    }
    
    @objc func sureButtonAction() {
        hideSheetViewAnimate(isSure: true)
    }
    
    func hideSheetViewAnimate(isSure: Bool) {
        
        UIView.animate(withDuration: 1.3, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.sheetView.frame = CGRect(x: CGFloat(0), y: self.bounds.height, width: self.bounds.width, height: CGFloat(self.sheetHeigt))
        }, completion: { (_) in
            if isSure == true {
                self.delegate?.selectButtonClickSex(sex: self.sexStr)
            }
            else {
                self.delegate?.cancelChooseUserSex()
            }
            self.sexStr = nil
        })
    }
    
    func showSheetViewAnimate(sex: String?) {
        UIView.animate(withDuration: 1.3, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.sheetView.frame = CGRect(x: CGFloat(0), y: self.bounds.height - CGFloat(self.sheetHeigt), width: self.bounds.width, height: CGFloat(self.sheetHeigt))
        }, completion: { (_) in
            self.scrollPickerRow(sex: sex)
        })
    }
    
    private func scrollPickerRow(sex: String?) {
        self.sexStr = sex
        if sex != nil {
            var row = 0
            switch sex {
            case "m":
                row = 0
            case "f":
                row = 1
            default:
                row = 2
            }
            pickerView.selectRow(row, inComponent: 0, animated: true)
        }
    }
    
    func configView() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        topButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        self.addSubview(topButton)
        
        sheetView.backgroundColor = UIColor(hexString: "#f5f5f5")
        self.addSubview(sheetView)
        
        setButtonStyle(button: cancelButton, title: "取消")
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        sheetView.addSubview(cancelButton)
        
        setButtonStyle(button: sureButton, title: "确定")
        sureButton.addTarget(self, action: #selector(sureButtonAction), for: .touchUpInside)
        sheetView.addSubview(sureButton)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .white
        sheetView.addSubview(pickerView)
    }
    
    func setViewConstraint() {
        
        topButton.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.bottom.equalTo(self).offset(-sheetHeigt)
        }
        
        sheetView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self).offset(sheetHeigt)
            make.height.equalTo(sheetHeigt)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(sheetView).offset(12)
            make.top.equalTo(sheetView)
            make.size.equalTo(CGSize(width: 58, height: 44))
        }
        
        sureButton.snp.makeConstraints { (make) in
            make.right.equalTo(sheetView).offset(-12)
            make.top.equalTo(sheetView)
            make.size.equalTo(CGSize(width: 58, height: 44))
        }
        
        pickerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(sheetView)
            make.top.equalTo(sureButton.snp.bottom)
        }
    }
    
    func setButtonStyle(button: UIButton, title: String) {
        button.setTitleColor(UIColor(hexString: "#0f80bf"), for: .normal)
        button.titleLabel?.font = UIFont(name: "#0f80bf", size: 14)
        button.setTitle(title, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TDSelectSexView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return "男"
        case 1:
            return "女"
        default:
            return "保密"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 39
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            self.sexStr = "m"
        case 1:
            self.sexStr = "f"
        default:
            self.sexStr = "o"
        }
    }
}
