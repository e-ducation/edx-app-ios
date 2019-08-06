//
//  TDScanQRViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/8/1.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit
import AVFoundation

class TDScanQRViewController: UIViewController {

    let scanQRView = TDScanQRView()
    var beepPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = Strings.scanCode
        self.view.backgroundColor = .black
        setViewConstraint()
        playAudioFile()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        scanQRView.startAnimation()
        startScanQR()
        
        //禁止手势返回
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//        changeNavigationBarColor(isBlack: true)
//        UINavigationBar.appearance().barStyle = UIBarStyle.default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        changeNavigationBarColor(isBlack: false)
//        UINavigationBar.appearance().barStyle = UIBarStyle.black
    }
    
    // 会话
    lazy var session: AVCaptureSession = {
        let session = AVCaptureSession()
        return session
    }()
    
    // 创建预览图层
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer.frame = self.view.bounds
        return previewLayer
    }()
    
    // 创建用于绘制边线的图层
    lazy var drawLayer: CALayer = {
        let drawLayer = CALayer()
        drawLayer.frame = self.view.bounds
        return drawLayer
    }()

    //MARK: 开始扫描
    func startScanQR() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("get audio AVCaptureDevice  failed!")
            return
        }
        // 拿到输入设备
        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            print("get audio AVCaptureDeviceInput  failed!")
            return
        }
        
        if session.canAddInput(deviceInput) == false {// 1.判断是否能够将输入添加到会话中
            return
        }
        
        let dataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(dataOutput) == false {// 2.判断是否能够将输出添加到会话中
            return
        }
        
        session.addInput(deviceInput)
        session.addOutput(dataOutput)
        
        // 4.设置输出能够解析的数据类型
        dataOutput.metadataObjectTypes = dataOutput.availableMetadataObjectTypes
        dataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let qrWidth = screenWidth*0.7
        let gap = screenWidth*0.3
        dataOutput.rectOfInterest = CGRect(x: 208/screenHeight, y: (gap/2)/screenWidth, width: qrWidth/screenHeight, height: 0.7)
        
        // 5.添加预览图层
        self.scanQRView.layer.insertSublayer(previewLayer, at: 0)
        // 添加绘制图层
        previewLayer.addSublayer(drawLayer)
        // 6.告诉session开始扫描
        session.startRunning()
    }
    
    func stopScan() {
        if session.isRunning == true {
            session.stopRunning()
        }
        scanQRView.stopAllAnimation()
    }
    
    //MARK: 播放bee声音
    func playAudioFile() {
        guard let wavPath = Bundle.main.path(forResource: "beep", ofType: "wav") else {
            print("找不到音频文件")
            return
        }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: wavPath))  else {
            print("获取不到音频文件数据")
            return
        }
        guard let beepPlayer = try? AVAudioPlayer(data: data) else {
            print("音频文件播放失败")
            return
        }
        self.beepPlayer = beepPlayer
    }
    
    //MARK: UI
    func setViewConstraint() {
        self.view.addSubview(scanQRView)
        scanQRView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view)
        }
    }
    
    func gotoConfirmVc(urlStr: String) {
        let confirmVc = TDAuthorConfirmViewController()
        confirmVc.authorUrl = urlStr
        confirmVc.popAction = { [weak self] in
            self?.navigationController?.popViewController(animated: false)
        }
        present(confirmVc, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension TDScanQRViewController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // 0.清空图层
        clearCorners()
        
        if metadataObjects.count == 0 {
            return
        }
        
        // 1.获取扫描到的数据
        // 注意: 要使用stringValue
        
        //判断是否有数据
        guard let metadataObj = metadataObjects.last as? AVMetadataMachineReadableCodeObject else {
            return
        }
        
        if metadataObj.type == .qr {
            stopScan()
            
            beepPlayer?.play()
            
            let result: String = metadataObj.stringValue ?? "没有结果"
            print("---->>>", result)
            gotoConfirmVc(urlStr: result)
            return
        }
        
        // 2.获取扫描到的二维码的位置
        // 2.1转换坐标
        for object in metadataObjects {
            guard let dataObj = object as? AVMetadataMachineReadableCodeObject else {
                return
            }
            previewLayer.transformedMetadataObject(for: object)
            drawCorners(codeObject: dataObj)
        }
    }
    
    //画出二维码的边框; codeObject 保存了坐标的对象
    func drawCorners(codeObject: AVMetadataMachineReadableCodeObject) {
        if codeObject.corners.count == 0 {
            return
        }
        
        let layer = CAShapeLayer()
        layer.lineWidth = 4
        layer.strokeColor = UIColor.red.cgColor
        layer.fillColor = UIColor.clear.cgColor
        
        let path = UIBezierPath()
        var point = CGPoint.zero
        var index = 1
        
        
        point = CGPoint.init(dictionaryRepresentation: codeObject.corners[index] as! CFDictionary)!
        path.move(to: point)
        
        while index < codeObject.corners.count {
            index += 1
            point = CGPoint.init(dictionaryRepresentation: codeObject.corners[index] as! CFDictionary)!
            path.addLine(to: point)
        }
        
        path.close()
        layer.path = path.cgPath
        drawLayer.addSublayer(layer)
    }
    
    //清除边线
    func clearCorners() {
        guard let sublayers = drawLayer.sublayers else {
            return
        }
        
        if sublayers.count == 0 {
            return
        }
        
        for subLayer in sublayers {
            subLayer.removeFromSuperlayer()
        }
    }
}
