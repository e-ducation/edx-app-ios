//
//  TDSearchCourseViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/7/19.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDSearchCourseViewController: UIViewController {

    typealias Environment = NetworkManagerProvider & OEXRouterProvider & OEXSessionProvider & OEXConfigProvider & OEXAnalyticsProvider
    private let environment : Environment
    
    let searchTopView = TDSearchTopView()
    let tableView = UITableView()
    
    var searchStr: String = ""
    var dataArray = Array<OEXCourse>()
    
    init(environment : Environment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setSearchNav()
        setViewConstraint()
    }
    
    func setSearchNav() {
        
//        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
//        searchBar.placeholder = "请输入"
//        searchBar.layer.cornerRadius = 15.0
//        searchBar.layer.masksToBounds = true
//        searchBar.showsCancelButton = true
//        searchBar.barStyle = .default
////        searchBar.delegate = self
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
//        titleView.addSubview(searchBar)
        
        searchTopView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width-48, height: 30)
        titleView.addSubview(searchTopView)
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.titleView?.sizeToFit()
        self.navigationItem.titleView = titleView
    }
    
    func setViewConstraint() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor(hexString: "#f5f5f5")
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(view)
        }
    }
    
    //MARK: 数据
    func gatCourseData() {
        
        let dic = NSMutableDictionary()
        dic.setValue("\(0)", forKey: "page_index")
        dic.setValue("\(1000)", forKey: "page_size")
        dic.setValue(searchStr, forKey: "search_name")
        
        let host = OEXConfig.shared().apiHostURL()?.absoluteString
        let path = host! + APP_COURSE_SEACH__URL
        
        let manager = AFHTTPSessionManager()
        manager.get(path, parameters: dic, progress: nil, success: { (task, response) in
            
            self.dataArray.removeAll()
            
            let responseDic = response as! Dictionary<String, Any>
            let results: Array<Dictionary<String, Any>> = responseDic["results"] as! Array<Dictionary<String, Any>>
            if results.count > 0 {
                for dic in results {
                    let model = OEXCourse.init(dictionary: dic)
                    self.dataArray.append(model)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            
        }) { (task, error) in
            
        }
    }
}

extension TDSearchCourseViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataArray.count == 0 && searchStr.count > 0 {
            return 1
        }
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.dataArray.count == 0 && searchStr.count > 0 {
            let cell = TDStudyNonCell(style: .default, reuseIdentifier: AccountViewCell.identifier)
            cell.hiddenButton = true
            cell.messageStr = "暂无搜索结果"
            cell.iconStr = "search_non_course"
            
            return cell
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "searchCell")
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "searchCell")
        }
        cell?.textLabel?.font = UIFont(name: "PingFang-SC-Regular", size: 16)
        cell?.textLabel?.textColor = UIColor(hexString: "#2e313c")
        
        let model = self.dataArray[indexPath.row]
        cell?.textLabel?.text = model.name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.dataArray.count == 0 && searchStr.count > 0 {
            return 325
        }
        return 43
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = self.dataArray[indexPath.row]
        coursesTableChoseCourse(course: model)
    }
    
    func coursesTableChoseCourse(course: OEXCourse) {
        if let course_id = course.course_id {
            self.environment.router?.showCourseWithID(courseID: course_id, fromController: self, animated: true)
        }
        else {
            preconditionFailure("course without a course id")
        }
    }
    
}
