//
//  TDArticlePageViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/4/16.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDArticlePageViewController: UIViewController {
    
    let segmentVC = TDSegmentedPageViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "文章"
        self.view.backgroundColor = UIColor.white
        
        loadTagData()
    }
    
    func loadTagData() {
        
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        
        let dic = NSMutableDictionary()
        dic.setValue("_,name", forKey: "fields")
        
        let host = OEXConfig.shared().apiHostURL()?.absoluteString
        let path = host! + APP_ARTICLE_TAGS_URL
        
        let manager = AFHTTPSessionManager()
        manager.get(path, parameters: dic, progress: nil, success: { (task, response) in
            
            SVProgressHUD.dismiss()
            
            let responseDic = response as! Dictionary<String, Any>
            let tagArray: Array<Any> = responseDic["items"] as! Array<Any>
            if tagArray.count > 0 {
                self.setTagDate(tagArray: tagArray)
            }
            
        }) { (task, error) in
            SVProgressHUD.dismiss()
            self.view.makeToast("加载标签失败", duration: 0.8, position: CSToastPositionCenter)
        }
    }
    
    func setTagDate(tagArray: Array<Any>) {
        
        var array: Array<Any> = ["最新", "最热"]
        var vcArray: Array<Any> = [TDArticleViewController(tagStr: "最新", delegate: self), TDArticleViewController(tagStr: "最热", delegate: self)]
        for i in 0..<tagArray.count {
            
            let tagDic = tagArray[i] as? [String: Any]
            let tag: String = tagDic?["name"] as! String
            array.append(tag)
            
            let ocVC = TDArticleViewController(tagStr: tag, delegate: self)
            vcArray.append(ocVC)
        }
        
        segmentVC.pageViewControllers = (vcArray as! [UIViewController])
        segmentVC.categoryView.titles = array as? [String]
        segmentVC.categoryView.originalIndex = 0
        
        self.addChild(segmentVC)
        self.view.addSubview(segmentVC.view)
        segmentVC.didMove(toParent: self)
        segmentVC.view.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view)
        }
    }

}

extension TDArticlePageViewController: TDArticleViewControllerDelegate {
    func selectArticleForHtml(didSelct htmlStr: String) {
        let webVC = TDDetailWebViewController(detailStr: htmlStr)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(webVC, animated: true)
    }
}
