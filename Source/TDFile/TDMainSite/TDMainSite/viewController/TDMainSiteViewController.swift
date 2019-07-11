//
//  TDMainSiteViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/4/16.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

enum MainSiteCellKey: String {
    case Banner = "TDMainSiteBannerCell"
    case CourseCategory = "TDCourseCategoryCell"
    case CourseSeries = "TDFindSuiteCell"
    case RecommendCourse = "TDRecommendCoureseCell"
    case Professor = "TDMainProfessorCell"
    case RecommendImg = "TDRecommendImageCell"
    case RecommendArticle = "TDRecommendArticleCell"
    case BeingVip = "TDBeingVipCell"
}

enum MainSiteReuseViewKey: String {
    case Header = "TDMainSiteHeaderView"
    case Footer = "TDMainSiteFooterReusableView"
}

class TDMainSiteViewController: UIViewController {
    
    private let loadController = LoadStateViewController()
    
    var mainSiteModel: TDMainSiteModel?
    
    lazy var collectionView : UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.bounces = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white
        
        collectionView.register(TDMainSiteBannerCell.self, forCellWithReuseIdentifier: MainSiteCellKey.Banner.rawValue)
        collectionView.register(TDCourseCategoryCell.self, forCellWithReuseIdentifier: MainSiteCellKey.CourseCategory.rawValue)
        collectionView.register(TDFindSuiteCell.self, forCellWithReuseIdentifier: MainSiteCellKey.CourseSeries.rawValue)
        collectionView.register(TDRecommendCoureseCell.self, forCellWithReuseIdentifier: MainSiteCellKey.RecommendCourse.rawValue)
        collectionView.register(TDMainProfessorCell.self, forCellWithReuseIdentifier: MainSiteCellKey.Professor.rawValue)
        collectionView.register(TDRecommendImageCell.self, forCellWithReuseIdentifier: MainSiteCellKey.RecommendImg.rawValue)
        collectionView.register(TDRecommendArticleCell.self, forCellWithReuseIdentifier: MainSiteCellKey.RecommendArticle.rawValue)
        collectionView.register(TDBeingVipCell.self, forCellWithReuseIdentifier: MainSiteCellKey.BeingVip.rawValue)
        
        collectionView.register(TDMainSiteHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MainSiteReuseViewKey.Header.rawValue)
        collectionView.register(TDMainSiteFooterReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: MainSiteReuseViewKey.Footer.rawValue)
        
        return collectionView
    }()
    
    typealias Environment = NetworkManagerProvider & OEXRouterProvider & OEXSessionProvider & OEXConfigProvider & OEXAnalyticsProvider
    private let environment : Environment
    
    init(environment : Environment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Strings.elitemba
        setViewConstraint()
        getMainSiteData(isFirst: true)
    }
    
    func getMainSiteData(isFirst: Bool) {
        
        let dic = NSMutableDictionary()
        dic.setValue("/", forKey: "html_path")
        
        let host = OEXConfig.shared().apiHostURL()?.absoluteString
        let path = host! + App_MAIN_SITE_URL
        
        let manager = AFHTTPSessionManager()
        manager.get(path, parameters: dic, progress: nil, success: { (task, response) in
            
            let responseDic = response as! Dictionary<String, Any>
            self.mainSiteModel = TDMainSiteModel(dic: responseDic)
            self.collectionView.reloadData()
            
            if isFirst {
                self.loadController.state = .Loaded
                self.loadController.view.isHidden = true
            }
            else {
                self.collectionView.mj_header.endRefreshing()
            }
            
        }) { (task, error) in
            if isFirst {
                self.showError(error: error as NSError)
            }
            else {
                self.view.makeToast(Strings.internetError, duration: 0.8, position: CSToastPositionCenter)
                self.collectionView.mj_header.endRefreshing()
            }
        }
    }
    
    public func showError(error : NSError?, icon : Icon? = nil, message : String? = nil) {
        let buttonInfo = MessageButtonInfo(title: Strings.reload) {[weak self] in
            self?.loadController.state = .Initial
            self?.getMainSiteData(isFirst: true)
        }
        loadController.state = LoadState.failed(error: error, icon: icon, message: message, buttonInfo: buttonInfo)
    }
    
    //MARK: UI
    func setViewConstraint() {
    
        self.view.backgroundColor = UIColor(hexString: "#f5f5f5")
        
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self.view)
        }
        
        loadController.setupInController(controller: self, contentView: collectionView)
        loadController.state = .Initial
        
        let header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(refreshData))
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.stateLabel.isHidden = true
        collectionView.mj_header = header
    }
    
    @objc func refreshData() {
        getMainSiteData(isFirst: false)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension TDMainSiteViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0,1,2:
            return 1
        case 3:
            return mainSiteModel?.courseArray.count ?? 0
        case 4:
            return mainSiteModel?.professorArray.count ?? 0
        case 5:
            return mainSiteModel?.storyImgArray.count ?? 0
        case 6:
            return mainSiteModel?.storyArray.count ?? 0
        default:
           return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell : TDMainSiteBannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: MainSiteCellKey.Banner.rawValue, for: indexPath) as! TDMainSiteBannerCell
            cell.delegate = self
            cell.dealwithBannerData(bannerArray: mainSiteModel?.bannerArray, loodTime: mainSiteModel?.loop_time)
            return cell
        case 1:
            let cell : TDCourseCategoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: MainSiteCellKey.CourseCategory.rawValue, for: indexPath) as! TDCourseCategoryCell
            cell.delegate = self
            cell.setDataArray(array: mainSiteModel?.categoryArray)
            return cell
        case 2:
            let cell : TDFindSuiteCell = collectionView.dequeueReusableCell(withReuseIdentifier: MainSiteCellKey.CourseSeries.rawValue, for: indexPath) as! TDFindSuiteCell
            cell.delegate = self
            cell.setDataArray(array: mainSiteModel?.seriesArray)
            return cell
        case 3:
            let model = mainSiteModel?.courseArray[indexPath.row]
            let cell : TDRecommendCoureseCell = collectionView.dequeueReusableCell(withReuseIdentifier: MainSiteCellKey.RecommendCourse.rawValue, for: indexPath) as! TDRecommendCoureseCell
            cell.model = model
            return cell
            
        case 4:
            let model = mainSiteModel?.professorArray[indexPath.row]
            let cell : TDMainProfessorCell = collectionView.dequeueReusableCell(withReuseIdentifier: MainSiteCellKey.Professor.rawValue, for: indexPath) as! TDMainProfessorCell
            cell.model = model
            return cell
        case 5:
            let cell : TDRecommendImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: MainSiteCellKey.RecommendImg.rawValue, for: indexPath) as! TDRecommendImageCell
            cell.model = mainSiteModel?.storyImgArray[indexPath.row]
            return cell
        case 6:
            let cell : TDRecommendArticleCell = collectionView.dequeueReusableCell(withReuseIdentifier: MainSiteCellKey.RecommendArticle.rawValue, for: indexPath) as! TDRecommendArticleCell
            cell.model = mainSiteModel?.storyArray[indexPath.row]
            return cell
        default:
            let cell : TDBeingVipCell = collectionView.dequeueReusableCell(withReuseIdentifier: MainSiteCellKey.BeingVip.rawValue, for: indexPath) as! TDBeingVipCell
            cell.imageUrl = mainSiteModel?.vipImageUrl
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 3 {
             return UIEdgeInsets(top: 0, left: 12, bottom: 18, right: 12)
        }
        if section == 4 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 3 {
            return 12
        }
        else if section == 4 {
            return 0
        }
        else if section == 6 {
            return 0
        }
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.size.width
        switch indexPath.section {
        case 0:
            return CGSize(width: screenWidth, height: (screenWidth-24)*0.47+24)
        case 1:
            return CGSize(width: screenWidth, height: 112)
        case 2:
            return CGSize(width: screenWidth, height: (screenWidth-24)*0.55*0.63+22)
        case 3:
            let width = (screenWidth-32)/2
            return CGSize(width: width, height: width * 0.56 + 32)
        case 4:
            return CGSize(width: screenWidth , height: 85)
        case 5:
            let model = mainSiteModel?.storyImgArray[indexPath.row]
            let height = heightForLabel(model: model)
            return CGSize(width: screenWidth , height: (screenWidth-24)*0.45 + (screenWidth-32)/2*0.58 + 39 + height)
        case 6:
            return CGSize(width: screenWidth, height: 113)
        default:
            return CGSize(width: screenWidth, height: (screenWidth-24)*0.37 + 36)
        }
    }
    
    func heightForLabel(model: TDMainSiteStoryModel?) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth - 24, height: 0))
        label.font = UIFont(name: "PingFang-SC-Medium", size: 15.0)
        label.numberOfLines = 2
        label.text = model?.story_title
        label.sizeToFit()
        return label.bounds.size.height
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        if kind == UICollectionView.elementKindSectionHeader {
            let section = indexPath.section
            
            if section == 0 || section == 6 || section == 7 {
                return UICollectionReusableView()
            }
            
            let headerView: TDMainSiteHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MainSiteReuseViewKey.Header.rawValue, for: indexPath) as! TDMainSiteHeaderView
            
            var titleStr = ""
            var moreTitle = ""
            var hasRight = true
            
            if section == 1 {
                titleStr = mainSiteModel?.categoryTitle ?? "课程分类"
                hasRight = false
            }
            else if section == 2 {
                titleStr = mainSiteModel?.seriesTitle ?? "找到合适您的课程"
                hasRight = false
            }
            else if section == 3 {
                titleStr = mainSiteModel?.courseTitle ?? "推荐课程"
                moreTitle = "全部课程"
            }
            else if section == 4 {
                titleStr = mainSiteModel?.professorTitle ?? "推荐教授"
                moreTitle = "全部教授"
            }
            else if section == 5 {
                titleStr = mainSiteModel?.storyTitle ?? "用户故事"
                moreTitle = "全部文章"
            }
            headerView.titleStr = titleStr
            headerView.hasRight = hasRight
            headerView.moreTitle = moreTitle
            
            headerView.moreButton.tag = section
            headerView.moreButton.addTarget(self, action: #selector(moreButtonAction(sender:)), for: .touchUpInside)
            return headerView
        }
        else {
            let footerView: TDMainSiteFooterReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: MainSiteReuseViewKey.Footer.rawValue, for: indexPath) as! TDMainSiteFooterReusableView
            return footerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0,6,7:
            return CGSize.zero
        default:
            let screenWidth = UIScreen.main.bounds.size.width
            return CGSize(width: screenWidth, height: 62)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let screenWidth = UIScreen.main.bounds.size.width
        switch section {
        case 0,1,5,6,7:
            return CGSize.zero
        default:
            return CGSize(width: screenWidth, height: 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        if section == 3 {
            let model = mainSiteModel?.courseArray[indexPath.row]
            recommendChoseCourse(course: model)
        }
        else if section == 4 {
            
            let model = mainSiteModel?.professorArray[indexPath.row]
            let subStr = "professors/"
            if let link = model?.professor_link, link.contains(find: subStr) {
                let rage = link.range(of: subStr)
                let edxIndex = link.index(link.endIndex, offsetBy: -1)
                let professorId = link[(rage?.upperBound)!..<edxIndex]
                
                let detailVC = TDProdessorWebViewController(detailID: String(professorId))
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
        else if section == 5 {
            let model = mainSiteModel?.storyImgArray[indexPath.row] //mainSiteModel?.storyModel
            selectDetail(didSelct: model?.story_link)
        }
        else if section == 6 {
            let model = mainSiteModel?.storyArray[indexPath.row]
            selectDetail(didSelct: model?.story_link)
        }
        else if section == 7 {
           gotoVipIntroduce()
        }
    }
    
    func selectDetail(didSelct htmlStr: String?) {
        if let urlStr = htmlStr, urlStr.count > 0 {
            if let host = OEXConfig.shared().apiHostURL()?.absoluteString,
                urlStr == host + "/vip" {
                gotoVipIntroduce()
            }
            else {
                let webVC = TDDetailWebViewController(detailStr: urlStr)
                webVC.blockHandle = { [weak self] in
                    let articleVc = TDArticlePageViewController()
                    self?.navigationController?.pushViewController(articleVc, animated: false)
                }
                self.navigationController?.pushViewController(webVC, animated: true)
            }
        }
        else {
            print("链接为空")
        }
    }
    
    func gotoVipIntroduce() {
        let username = self.environment.session.currentUser?.username ?? ""
        
        let vipVc = TDVipIntroduceViewController()
        vipVc.username = username;
        vipVc.urlStr = "/vip?device=ios"
        vipVc.gotoCategoryHandle = { [weak self] in
            self?.environment.router?.showCourseCatalog(fromController: self)
        }
        self.navigationController?.pushViewController(vipVc, animated: true)
    }
    
    func recommendChoseCourse(course: TDMainSiteCourseModel?) {
        
        guard let courseID = course?.link, courseID.count > 0 else {
            return
        }
        
        if let pageUrl = course?.pageUrl, pageUrl.count > 0, let courseTitle = course?.title {
            let webVC = TDCoursePageWebViewController(environment: self.environment, detailStr: pageUrl, titleStr: courseTitle, courseID: courseID)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(webVC, animated: true)
            return
        }
        
        self.environment.router?.showCourseCatalogDetail(courseID: courseID, fromController:self)
    }
    
    //MARK: action
    @objc func moreButtonAction(sender: UIButton) {
        if sender.tag == 3 {//发现课程
            self.environment.router?.showCourseCatalog(fromController: self)
        }
        else if sender.tag == 4 {
            let professorVc = TDProfessorViewController()
            self.navigationController?.pushViewController(professorVc, animated: true)
        }
        else if sender.tag == 5 {
            let articleVc = TDArticlePageViewController()
            self.navigationController?.pushViewController(articleVc, animated: true)
        }
    }
}

extension TDMainSiteViewController: CourseCategoryDelegate, CourseSeriesDelegate, MainSiteBannersDelegate {
    //MARK: CourseCategoryDelegate
    func courseCategoryDidSelect(index: NSInteger) {
        let model = mainSiteModel?.categoryArray[index]
        selectDetail(didSelct: model?.categories_link)
    }
    //MARK: CourseSeriesDelegate
    func couseSeriesSelect(index: NSInteger) {
        let model = mainSiteModel?.seriesArray[index]
        selectDetail(didSelct: model?.link)
    }
    
    //MARK: MainSiteBannersDelegate
    func mainSiteBannersSelect(index: NSInteger) {
        let model = mainSiteModel?.bannerArray[index]
        selectDetail(didSelct: model?.link)
    }
}
