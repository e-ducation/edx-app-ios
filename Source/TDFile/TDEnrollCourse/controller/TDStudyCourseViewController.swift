//
//  TDStudyCourseViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/7/23.
//  Copyright © 2019 edX. All rights reserved.
//

import Foundation

class TDStudyCourseViewController : OfflineSupportViewController, TDStudyTableViewControllerDelegate, LoadStateViewReloadSupport,InterfaceOrientationOverriding {
    
    typealias Environment = OEXAnalyticsProvider & OEXConfigProvider & DataManagerProvider & NetworkManagerProvider & ReachabilityProvider & OEXRouterProvider & OEXSessionProvider & OEXStylesProvider
    
    var courseID = ""
    var showHarvard = false
    let userProfileManager : UserProfileManager
    
    private let environment : Environment
    private let tableController : TDStudyTableViewController
    private let loadController = LoadStateViewController()
    fileprivate let enrollmentFeed: Feed<[UserCourseEnrollment]?>
    private let userPreferencesFeed: Feed<UserPreference?>
    init(environment: Environment) {
        self.tableController = TDStudyTableViewController(environment: environment, context: .EnrollmentList)
        self.enrollmentFeed = environment.dataManager.enrollmentManager.feed
        self.userPreferencesFeed = environment.dataManager.userPreferenceManager.feed
        self.environment = environment
        self.userProfileManager = environment.dataManager.userProfileManager
        
        super.init(env: environment)
        self.navigationItem.title = Strings.courses
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.oex_addObserver(observer: self, name: GOTO_STUDYCORUSE_DASBORD) { (notification, observer, _) in
            if let courseID = notification.object as? String {
                self.courseID = courseID
            }
        }
        NotificationCenter.default.oex_addObserver(observer: self, name: GOTO_HARVARD_DETAIL) { (notification, observer, _) in
            self.showHarvard = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.accessibilityIdentifier = "enrolled-courses-screen"
        
        addChild(tableController)
        tableController.didMove(toParent: self)
        self.loadController.setupInController(controller: self, contentView: tableController.view)
        self.view.addSubview(tableController.view)
        
        let statusHeight = UIApplication.shared.statusBarFrame.height
        tableController.view.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(statusHeight)
        }
        tableController.delegate = self
        
        let header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(refreshData))
        header?.lastUpdatedTimeLabel.isHidden = true
        tableController.tableView.mj_header = header
        
        self.enrollmentFeed.refresh()
        self.userPreferencesFeed.refresh()
        
        setupProfileListener()
        setupListener()
        setupObservers()
        addFindCoursesButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        environment.analytics.trackScreen(withName: OEXAnalyticsScreenMyCourses)
        showVersionUpgradeSnackBarIfNecessary()
        
        super.viewWillAppear(animated)
        hideSnackBarForFullScreenError()
        
        //        enrollmentFeed.refresh()
        
        hideNavgationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //从详情直接跳到课程
        if courseID.count > 0 {
            self.environment.router?.showCourseWithID(courseID: courseID, fromController: self, animated: false)
            courseID = ""
        }
        
        //跳入哈商
        if showHarvard == true {
            showHarvard = false
            let day: Int = userProfileManager.feedForCurrentUser().output.value?.hmm_remaining_days ?? 0
            if day > 0 {
                self.havardCourseEnter()
            }
        }

    }
    
    override func reloadViewData() {
        refreshIfNecessary()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private var isCourseDiscoveryEnabled: Bool {
        return environment.config.discovery.course.isEnabled
    }
    
    private func addFindCoursesButton() {
        if environment.config.discovery.course.isEnabled {
            let findcoursesButton = UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil)
            findcoursesButton.accessibilityLabel = Strings.findCourses
            navigationItem.rightBarButtonItem = findcoursesButton
            
            findcoursesButton.oex_setAction { [weak self] in
                self?.environment.router?.showCourseCatalog(fromController: self, bottomBar: nil)
            }
        }
    }
    
    private func setupListener() {
        enrollmentFeed.output.listen(self) {[weak self] result in
            if !(self?.enrollmentFeed.output.active ?? false) {
                self?.tableController.tableView.mj_header.endRefreshing()
            }
            
            switch result {
            case let Result.success(enrollments):
                if let enrollments = enrollments {
                    self?.tableController.courses = enrollments.compactMap { $0.course }
                    self?.tableController.tableView.reloadData()
                    self?.loadController.state = .Loaded
                    if enrollments.count <= 0 {
                        self?.enrollmentsEmptyState()
                    }
                }
                else {
                    self?.loadController.state = .Initial
                }
            case let Result.failure(error):
                //App is showing occasionally error on app launch, so skipping first error on app launch
                //TODO: Find exact root cause of error and remove this patch
                // error code -100 is for unknown error
                if error.code == -100 {
                    return
                }
                
                self?.loadController.state = LoadState.failed(error: error)
                if error.errorIsThisType(NSError.oex_outdatedVersionError()) {
                    self?.hideSnackBar()
                }
            }
        }
    }
    
    private func enrollmentsEmptyState() {
        if !isCourseDiscoveryEnabled {
            let error = NSError.oex_error(with: .unknown, message: Strings.EnrollmentList.noEnrollment)
            loadController.state = LoadState.failed(error: error, icon: Icon.UnknownError)
        }
    }
    
    private func setupObservers() {
        let config = environment.config
        NotificationCenter.default.oex_addObserver(observer: self, name: NSNotification.Name.OEXExternalRegistrationWithExistingAccount.rawValue) { (notification, observer, _) -> Void in
            let platform = config.platformName()
            let service = notification.object as? String ?? ""
            let message = Strings.externalRegistrationBecameLogin(platformName: platform, service: service)
            observer.showOverlay(withMessage: message)
        }
        
        NotificationCenter.default.oex_addObserver(observer: self, name: AppNewVersionAvailableNotification) { (notification, observer, _) -> Void in
            observer.showVersionUpgradeSnackBarIfNecessary()
        }
    }
    
    func refreshIfNecessary() {
        if environment.reachability.isReachable() && !enrollmentFeed.output.active {
            enrollmentFeed.refresh()
            if loadController.state.isError {
                loadController.state = .Initial
            }
        }
    }
    
    private func showVersionUpgradeSnackBarIfNecessary() {
        if let _ = VersionUpgradeInfoController.sharedController.latestVersion {
//            var infoString = Strings.VersionUpgrade.newVersionAvailable
//            if let _ = VersionUpgradeInfoController.sharedController.lastSupportedDateString {
//                infoString = Strings.VersionUpgrade.deprecatedMessage
//            }
            
//            if !isActionTakenOnUpgradeSnackBar {
//                showVersionUpgradeSnackBar(string: infoString)
//            }
        }
        else {
            hideSnackBar()
        }
    }
    
    private func hideSnackBarForFullScreenError() {
        if tableController.courses.count <= 0 {
            hideSnackBar()
        }
    }
    //MARK: TDStudyTableViewControllerDelegate
    func coursesTableChoseCourse(course: OEXCourse) {
        if let course_id = course.course_id {
            self.environment.router?.showCourseWithID(courseID: course_id, fromController: self, animated: true)
        }
        else {
            preconditionFailure("course without a course id")
        }
    }
    
    func clickExpiredButton() {
        let username = self.environment.session.currentUser?.username ?? ""
        
        let packageVC = TDVipPackageViewController()
        packageVC.username = username
        packageVC.vipBuySuccessHandle = { [weak self] in
            self?.enrollmentFeed.refresh()
        }
        self.navigationController?.pushViewController(packageVC, animated: true)
    }
    
    func havardCourseEnter() {
        let day: Int = userProfileManager.feedForCurrentUser().output.value?.hmm_remaining_days ?? 0
        if day  > 0 {//哈佛学习营
            self.authenWebView()
        }
        else {
            self.environment.router?.showCourseCatalog(fromController: self, bottomBar: nil)
        }
    }
    
    func gotoFindCourse() {
        self.environment.router?.showCourseCatalog(fromController: self, bottomBar: nil)
    }
    
    @objc func refreshData() {
        self.enrollmentFeed.refresh()
        self.userPreferencesFeed.refresh()
    }
    
    //MARK:- LoadStateViewReloadSupport method
    func loadStateViewReload() {
        refreshIfNecessary()
    }
    
}

extension TDStudyCourseViewController {
    
    func authenWebView() {
        let webController = AuthenticatedWebViewController(environment: environment)
        webController.title = Strings.harvardLearnCampTitle

        let hmmUrl: String = userProfileManager.feedForCurrentUser().output.value?.hmm_entry_url ?? ""
        if let hostUrl = environment.config.apiHostURL() {
            let url = hostUrl.appendingPathComponent(hmmUrl)
            let request = NSMutableURLRequest(url: url)
            webController.loadRequest(request: request)
            self.navigationController?.pushViewController(webController, animated: true)
        }
    }

    func setupProfileListener() {
        let feed = userProfileManager.feedForCurrentUser()
        feed.output.listen(self) { (result) in
            let date: String = feed.output.value?.hmm_expiry_date ?? ""
            let day: Int = feed.output.value?.hmm_remaining_days ?? 0

            self.tableController.days = day
            self.tableController.dateStr = date
            self.tableController.tableView.reloadData()
        }
    }
}
