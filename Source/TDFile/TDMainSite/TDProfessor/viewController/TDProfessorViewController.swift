//
//  TDProfessorViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/4/16.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDProfessorViewController: UIViewController {

    let tableview = UITableView()
    var dataArray = Array<TDProfessorModel>()
    private let loadController = LoadStateViewController()
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "教授"
        setViewConstraint()
        
        loadController.setupInController(controller: self, contentView: tableview)
        loadController.state = .Initial
        
        getData(isRefresh: true)
    }
    
    func getData(isRefresh: Bool) {
        if isRefresh == true {
            self.tableview.mj_footer.resetNoMoreData()
        }
        
        let dic = NSMutableDictionary()
        dic.setValue("\(page)", forKey: "page")
        dic.setValue("10", forKey: "page_size")
        
        let host = OEXConfig.shared().apiHostURL()?.absoluteString
        let path =  host! + APP_PROFESSOR_LIST_URL
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
            
            let pages = responseDic["num_pages"] as? Int
            if self.page >= pages! {
                self.tableview.mj_footer.endRefreshingWithNoMoreData()
            }
            else {
                self.page += 1
            }

            let results: Array<Dictionary<String, Any>> = responseDic["results"] as! Array<Dictionary<String, Any>>
            if results.count > 0 {
                for dic in results {
                    let model: TDProfessorModel = TDProfessorModel(dict: dic)!
                    self.dataArray.append(model)
                }
                DispatchQueue.main.async {
                    self.tableview.reloadData()
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
        self.view.backgroundColor = UIColor(hexString: "#f9f9f9");
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = UIColor.white
        tableview.separatorColor = UIColor(hexString: "#f5f5f5")
        self.view.addSubview(self.tableview);
        self.tableview.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view);
        }
        
        let header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(refreshData))
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.stateLabel.isHidden = true
        tableview.mj_header = header
        
        let footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        footer?.setTitle("", for: .refreshing)
        footer?.setTitle("", for: .willRefresh)
        footer?.setTitle("", for: .idle)
        footer?.setTitle("", for: .pulling)
        footer?.setTitle("———— 这个是底线 ————", for: .noMoreData)
        footer?.stateLabel.textColor = UIColor(hexString: "#ccd1d9")
        footer?.stateLabel.font = UIFont(name: "PingFangSC-Medium", size: 12)
        tableview.mj_footer = footer
    }
    
    @objc func refreshData() {
        page = 1
        getData(isRefresh: true)
        print("刷新")
    }
    
    @objc func loadMoreData() {
        getData(isRefresh: false)
        print("加载更多")
    }
}

extension TDProfessorViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.dataArray[indexPath.row]
        let cell = TDProfessorCell.init(style: .default, reuseIdentifier: "TDProfessorCell")
        cell.model = model
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 113
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        
        let model = self.dataArray[indexPath.row]
        if let professorId = model.id {
            let detailVC = TDProdessorWebViewController(detailID: String(professorId))
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
