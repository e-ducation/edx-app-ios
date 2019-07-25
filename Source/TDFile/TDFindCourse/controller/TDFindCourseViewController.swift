//
//  TDFindCourseViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/7/17.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

protocol TDFindCourseViewControllerDelegate: class {
    func coursesTableChoseCourse(course : OEXCourse)
}

class TDFindCourseViewController: UIViewController {

    let tableview = UITableView()
    let tagID: String?
    var dataArray = Array<OEXCourse>()
    var page = 1
    
    weak var delegate: TDFindCourseViewControllerDelegate?
    private let loadController = LoadStateViewController()
    
    init(tagID: String, delegate: TDFindCourseViewControllerDelegate) {
        self.tagID = tagID
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewConstraint()
        loadController.setupInController(controller: self, contentView: tableview)
        loadController.state = .Initial
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        gatCourseData(isRefresh: true)
    }
    
    //MARK: 数据
    func gatCourseData(isRefresh: Bool) {
        if isRefresh == true {
            self.tableview.mj_footer.resetNoMoreData()
        }
        
        let pageSize = 10
        let dic = NSMutableDictionary()
        dic.setValue("\(page)", forKey: "page_index")
        dic.setValue("\(pageSize)", forKey: "page_size")
        dic.setValue(tagID, forKey: "course_type_id")
        
        let host = OEXConfig.shared().apiHostURL()?.absoluteString
        let path = host! + APP_COURSE_SEACH__URL
        
        let manager = AFHTTPSessionManager()
        manager.get(path, parameters: dic, progress: nil, success: { (task, response) in
            
            self.loadController.state = .Loaded
            
            let responseDic = response as! Dictionary<String, Any>
            if isRefresh == true {
                self.page = 1
                self.dataArray.removeAll()
                self.tableview.mj_header.endRefreshing()
            }
            else {
                self.tableview.mj_footer.endRefreshing()
            }
            let pagDic = responseDic["pagination"] as! Dictionary<String, Any>
            let count = pagDic["count"] as? Int
            if self.page * pageSize >= count! {
                self.tableview.mj_footer.endRefreshingWithNoMoreData()
            }
            else {
                self.page += 1
            }
            
            let results: Array<Dictionary<String, Any>> = responseDic["results"] as! Array<Dictionary<String, Any>>
            if results.count > 0 {
                for dic in results {
                    let model = OEXCourse.init(dictionary: dic)
                    self.dataArray.append(model)
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                }
            }
            
        }) { (task, error) in
            self.loadController.state = LoadState.failed(error: error as NSError)
            if isRefresh == true {
                self.tableview.mj_header.endRefreshing()
            }
            else {
                self.tableview.mj_footer.endRefreshing()
            }
        }
    }
    
    //MARK: UI
    func setViewConstraint() {
        self.view.backgroundColor = UIColor.white;
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = UIColor(hexString: "#f9f9f9")
        tableview.separatorColor = UIColor(hexString: "#f5f5f5")
        self.view.addSubview(self.tableview);
        self.tableview.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view);
        }
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))
        header?.lastUpdatedTimeLabel.isHidden = true
        tableview.mj_header = header
        
        let footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer?.setTitle("", for: .noMoreData)
        tableview.mj_footer = footer
    }
    
    @objc func refreshData() {
        page = 1
        gatCourseData(isRefresh: true)
        print("刷新")
    }
    
    @objc func loadMoreData() {
        gatCourseData(isRefresh: false)
        print("加载更多")
    }
}

extension TDFindCourseViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataArray.count == 0 {
            return 1
        }
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.dataArray.count == 0 {
            let cell = TDStudyNonCell(style: .default, reuseIdentifier: AccountViewCell.identifier)
            cell.dataNonCell(message: "暂无课程", iconStr: "data_non_image", isHiddenButton: true, colorString: "#f9f9f9")
            return cell
        }
        
        let model = dataArray[indexPath.row]
        let cell = TDFindCourseCell.init(style: .default, reuseIdentifier: "TDArticleCell")
        cell.model = model
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.dataArray.count == 0 {
            return 325
        }
        return 123
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
  
        guard self.dataArray.count > 0 else {
            return
        }
        
        let model = dataArray[indexPath.row]
        self.delegate?.coursesTableChoseCourse(course: model)
    }
}
