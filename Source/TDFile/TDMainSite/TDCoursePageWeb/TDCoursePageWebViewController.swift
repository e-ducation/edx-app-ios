//
//  TDCoursePageWebViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/7/10.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit
import WebKit

class TDCoursePageWebViewController: UIViewController {

    private let webView = WKWebView(frame: CGRect.zero)
    private let htmlStr: String
    private let courseID: String
    
    private let loadController = LoadStateViewController()
    
    typealias Environment = NetworkManagerProvider & OEXRouterProvider & OEXSessionProvider & OEXConfigProvider & OEXAnalyticsProvider
    private let environment : Environment
    
    init(environment : Environment, detailStr: String, titleStr: String, courseID: String) {
        self.environment = environment
        self.htmlStr = detailStr
        self.courseID = courseID
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = titleStr
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewConstraint()
        loadHtml()
    }
    
    func loadHtml() {
        guard let url = URL(string: htmlStr + "?device=ios") else {
            return
        }
        let request = URLRequest(url: url)
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
}

extension TDCoursePageWebViewController: WKUIDelegate, WKNavigationDelegate {
    
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
        
        
        if let urlStr = navigationAction.request.url?.URLString, urlStr.contains(find: self.htmlStr) {
            decisionHandler(.allow)
        }
        else {
            
            if courseID.count > 0 {
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                self.environment.router?.showCourseCatalogDetail(courseID: courseID, fromController:self)
            }
            decisionHandler(.cancel)
        }
    }
}
