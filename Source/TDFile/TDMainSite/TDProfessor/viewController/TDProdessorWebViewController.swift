//
//  TDProdessorWebViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/4/18.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit
import WebKit

class TDProdessorWebViewController: UIViewController {

    var detailID: String
    
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect.zero)
        webView.sizeToFit()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        return webView
    }()
    
    private let loadController = LoadStateViewController()
    
    init(detailID: String) {
        self.detailID = detailID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "教授详情"
        setViewContraint()
        loadData()
    }
    
    func loadData() {
        
        let manager = AFHTTPSessionManager()
        
        let host = OEXConfig.shared().apiHostURL()?.absoluteString
        let path = host! + "/api/v1/professors/\(detailID)/"
        manager.get(path, parameters: nil, progress: nil, success: { (task, response) in
            
            let responseDic = response as! Dictionary<String, Any>
            if responseDic.count > 0 {
                let detail: String = responseDic["professor_info"] as! String
                self.loadRequestWebView(htmlStr: detail)
            }
            else {
               self.loadController.state = .Loaded
                self.view.makeToast("暂无数据", duration: 0.8, position: CSToastPositionCenter)
            }
            
        }) { (task, error) in
            self.loadController.state = LoadState.failed(error: error as NSError)
        }
    }
    
    func loadRequestWebView(htmlStr: String) {
        
        guard let html = OEXStyles.shared().styleHTMLContent(htmlStr, stylesheet: "inline-content") else {
            return
        }
        
        let jsScript = "<div class=\"my-theme-course-about professor-detail\">\(html)</div>" + "<link rel=\"stylesheet\" type=\"text/css\" href=\"//oss.elitemba.cn/web_static/css/overview.css\" />"
        
        let host = OEXConfig.shared().apiHostURL()?.absoluteString
        webView.loadHTMLString(jsScript, baseURL: URL(string: host!))
    }
    
    func setViewContraint() {
        view.backgroundColor = UIColor.white
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(view)
        }
        
        loadController.setupInController(controller: self, contentView: webView)
    }

}

extension TDProdessorWebViewController: WKNavigationDelegate, WKUIDelegate  {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadController.state = .Initial
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadController.state = .Loaded
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadController.state = LoadState.failed(error: error as NSError)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //禁止缩放
        let javascript = "var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);"
        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
}
