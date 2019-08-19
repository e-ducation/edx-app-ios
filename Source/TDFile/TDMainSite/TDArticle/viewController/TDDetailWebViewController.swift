//
//  TDDetailWebViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/4/19.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit
import WebKit

class TDDetailWebViewController: UIViewController {
    
    let webView = WKWebView(frame: CGRect.zero)
    var htmlStr: String
    var approveSucess = true
    
    var blockHandle: (()->())?
    
    private let loadController = LoadStateViewController()
    
    init(detailStr: String) {
        self.htmlStr = detailStr
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "详情"
        setViewConstraint()
        loadApprovesStatus()
        loadHtml()
    }
    
    func loadHtml() {
        guard let url = URL(string: htmlStr + "?device=ios") else {
            return
        }
        let request = URLRequest(url: url)
        //网页中写入登录token
//         request.setValue("Bearer iektLLcXi8ienz5GCG6BbZSsGD7u0l", forHTTPHeaderField: "Authorization")
        webView.load(request)
    }
    
    func setViewConstraint() {
        
        self.view.backgroundColor = UIColor.white
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(view)
        }
        
        loadController.setupInController(controller: self, contentView: webView)
    }
    
    func loadApprovesStatus() {
        PurchaseManager.showPurchaseComplete { (approveSucess) in
            self.approveSucess = approveSucess
        }
    }
    
    func loadCookie() {
        let cookieStore = HTTPCookieStorage.shared
        let array = cookieStore.cookies
        for i in 0..<array!.count {
            let cookie = array?[i]
            print("打印 - \(String(describing: cookie))")
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension TDDetailWebViewController: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadController.state = .Initial
         print("开始加载")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //禁止缩放
        let javascript = "var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);"
        webView.evaluateJavaScript(javascript, completionHandler: nil)

        print("开始返回")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadController.state = .Loaded
        print("加载完成")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadController.state = LoadState.failed(error: error as NSError)
         print("加载失败")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadController.state = LoadState.failed(error: error as NSError)
        print("加载失败")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let urlStr = navigationAction.request.url?.absoluteString
        if urlStr == "eliteu://gotoArticleList" {
            if let block = blockHandle {
                self.navigationController?.popViewController(animated: false)
                block()
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
            decisionHandler(.cancel)
        }
        else if (urlStr?.contains(find: "device=ios"))! {
            decisionHandler(.allow)
        }
        else {
            switch navigationAction.navigationType {
            case .linkActivated,.formSubmitted,.formResubmitted :
                if approveSucess == true {
                    if let webUrl = navigationAction.request.url, UIApplication.shared.canOpenURL(webUrl) {
                        UIApplication.shared.openURL(webUrl)
                    }
                }
                decisionHandler(.cancel)
            case .backForward,.reload,.other:
                decisionHandler(.allow)
                print("backForward")
            } 
        }
    }
}
