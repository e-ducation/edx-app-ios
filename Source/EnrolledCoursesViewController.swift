//
//  EnrolledCoursesViewController.swift
//  edX
//
//  Created by Akiva Leffert on 12/21/15.
//  Copyright © 2015 edX. All rights reserved.
//

import Foundation

var isActionTakenOnUpgradeSnackBar: Bool = false

class EnrolledCoursesViewController : OfflineSupportViewController, CoursesTableViewControllerDelegate, PullRefreshControllerDelegate, LoadStateViewReloadSupport,InterfaceOrientationOverriding,UIGestureRecognizerDelegate {
    
    typealias Environment = OEXAnalyticsProvider & OEXConfigProvider & DataManagerProvider & NetworkManagerProvider & ReachabilityProvider & OEXRouterProvider & OEXSessionProvider & OEXStylesProvider & ReachabilityProvider
    
    private let environment : Environment
    private let tableController : CoursesTableViewController
    private let loadController = LoadStateViewController()
    private let refreshController = PullRefreshController()
    private let insetsController = ContentInsetsController()
    fileprivate let enrollmentFeed: Feed<[UserCourseEnrollment]?>
    private let userPreferencesFeed: Feed<UserPreference?>
    private let footer = EnrolledCoursesFooterView()
    init(environment: Environment) {
        self.tableController = CoursesTableViewController(environment: environment, context: .EnrollmentList)
        self.enrollmentFeed = environment.dataManager.enrollmentManager.feed
        self.userPreferencesFeed = environment.dataManager.userPreferenceManager.feed
        self.environment = environment
        
        super.init(env: environment)
        self.navigationItem.title = Strings.courses
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
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
        tableController.view.snp.makeConstraints { make in
            make.edges.equalTo(safeEdges)
        }
        tableController.delegate = self

        refreshController.setupInScrollView(scrollView: self.tableController.tableView)
        refreshController.delegate = self
        
        insetsController.setupInController(owner: self, scrollView: tableController.tableView)
        insetsController.addSource(source: self.refreshController)

        // We visually separate each course card so we also need a little padding
        // at the bottom to match
        insetsController.addSource(
            source: ConstantInsetsSource(insets: UIEdgeInsets(top: 0, left: 0, bottom: StandardVerticalMargin, right: 0), affectsScrollIndicators: false)
        )
        
        self.enrollmentFeed.refresh()
        self.userPreferencesFeed.refresh()
        
        setupProfileListener()
        setupListener()
        setupFooter()
        setupObservers()
        addFindCoursesButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        environment.analytics.trackScreen(withName: OEXAnalyticsScreenMyCourses)
        showVersionUpgradeSnackBarIfNecessary()

        super.viewWillAppear(animated)
        hideSnackBarForFullScreenError()
        showWhatsNewIfNeeded()
        showBindphoneAlertView()
        
//        enrollmentFeed.refresh()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        //设置statusbar地变颜色
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = .white
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
                self?.refreshController.endRefreshing()
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
    
    private func setupFooter() {
        if isCourseDiscoveryEnabled {
            footer.findCoursesAction = {[weak self] in
                let day: Int = self?.environment.dataManager.userProfileManager.feedForCurrentUser().output.value?.hmm_remaining_days ?? 0
                if day  > 0 {//哈佛学习营
                   self?.authenWebView()
                }
                else {
                    self?.environment.router?.showCourseCatalog(fromController: self, bottomBar: nil)
                }
            }

            footer.sizeToFit()
            self.tableController.tableView.tableFooterView = footer
        }
        else {
            tableController.tableView.tableFooterView = UIView()
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
            var infoString = Strings.VersionUpgrade.newVersionAvailable
            if let _ = VersionUpgradeInfoController.sharedController.lastSupportedDateString {
                infoString = Strings.VersionUpgrade.deprecatedMessage
            }
            
            if !isActionTakenOnUpgradeSnackBar {
                showVersionUpgradeSnackBar(string: infoString)
            }
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
    //MARK: CoursesTableViewControllerDelegate
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
        let day: Int = self.environment.dataManager.userProfileManager.feedForCurrentUser().output.value?.hmm_remaining_days ?? 0
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
    
    private func showWhatsNewIfNeeded() {
        if WhatsNewViewController.canShowWhatsNew(environment: environment as? RouterEnvironment) {
            environment.router?.showWhatsNew(fromController: self)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableController.tableView.autolayoutFooter()
    }
    
    //MARK:- PullRefreshControllerDelegate method
    func refreshControllerActivated(controller: PullRefreshController) {
        self.enrollmentFeed.refresh()
        self.userPreferencesFeed.refresh()
    }
    
    //MARK:- LoadStateViewReloadSupport method 
    func loadStateViewReload() {
        refreshIfNecessary()
    }
    
}

extension EnrolledCoursesViewController {
    
    func authenWebView() {
        let webController = AuthenticatedWebViewController(environment: environment)
        webController.title = Strings.harvardLearnCampTitle
        
        let hmmUrl: String = environment.dataManager.userProfileManager.feedForCurrentUser().output.value?.hmm_entry_url ?? ""
        if let hostUrl = environment.config.apiHostURL() {
            let url = hostUrl.appendingPathComponent(hmmUrl)
            let request = NSMutableURLRequest(url: url)
            webController.loadRequest(request: request)
            self.navigationController?.pushViewController(webController, animated: true)
        }
    }

    func setupProfileListener() {
        let feed = environment.dataManager.userProfileManager.feedForCurrentUser()
        feed.output.listen(self) { (result) in
            let date: String = feed.output.value?.hmm_expiry_date ?? ""
            
            let day: Int = feed.output.value?.hmm_remaining_days ?? 0
            self.footer.refreshFooterText(days: day, date: date)
            self.tableController.tableView.autolayoutFooter()
        }
    }
    
    func hmmDaysAlerWillShow() -> Bool {
        
        guard let profile = environment.dataManager.userProfileManager.feedForCurrentUser().output.value else {
            return false
        }
        
        let username = profile.username ?? ""
        var showAlert : Bool = false
        let day: Int = profile.hmm_remaining_days ?? 0
        
        let value : String = UserDefaults.standard.string(forKey: HARVARD_DAYS + username) ?? ""
        if (value.isEmpty) {
            
            if day > 0 && day <= 7 {
                showAlert = true
                hmmDaysAlertView(type: 2)
            }
            else if day > 7 && day <= 30 {
                showAlert = true
                hmmDaysAlertView(type: 1)
            }
            else {
                showAlert = false
            }
        }
        else {//不为空
            
            if day > 0 && day <= 7 && Int(value) != 2 {
                showAlert = true
                hmmDaysAlertView(type: 2)
            }
            else if day > 7 && day < 30 && Int(value) != 1 {
                showAlert = true
                hmmDaysAlertView(type: 1)
            }
            else {
                showAlert = false
            }
            
        }
        return showAlert
    }
    
    func hmmDaysAlertView(type: Int) {
        let message = type == 1 ? Strings.harvardMoth : Strings.harvardSevendDay
        let alertController = UIAlertController(title: Strings.systemReminder, message: message, preferredStyle: .alert)
        
        let sureAction = UIAlertAction(title: Strings.goNow, style: .default) { [weak self](action) in
            let username = self?.environment.session.currentUser?.username ?? ""
            UserDefaults.standard.setValue("\(type)", forKey: HARVARD_DAYS + username)
        }
        alertController.addAction(sureAction)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    func showBindphoneAlertView() {
        
        guard let profile = environment.dataManager.userProfileManager.feedForCurrentUser().output.value else {
            return
        }
        
        if hmmDaysAlerWillShow() { //如果提示商学院
            return
        }
        
        guard profile.phone?.isEmpty == true else {//空的时候
            return
        }
        
        if phoneBindAlerDidShow() {//已提示过绑定手机
            return
        }
        
        let alertController = UIAlertController(title: Strings.systemReminder, message: Strings.realnameRequirement, preferredStyle: .alert)
        let sureAction = UIAlertAction(title: Strings.bindPhoneText, style: .default) { [weak self](action) in
            let bindPhoneVc = TDBindPhoneViewController()
            bindPhoneVc.bindingPhoneSuccess = { [weak self] in
                self?.reloadProfileChange()
            }
            self?.navigationController?.pushViewController(bindPhoneVc, animated: true)
        }
        let cancelAction = UIAlertAction(title: Strings.nextTime, style: .destructive) { (action) in
            
        }
        alertController.addAction(cancelAction)
        alertController.addAction(sureAction)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    func phoneBindAlerDidShow() -> Bool {

        let username = self.environment.session.currentUser?.username ?? ""
        var showAlert : Bool = true
        let formater = DateFormatter.init()
        formater.dateFormat = "yyyy-MM-dd"

        let key = BIND_PHONE_ALERTVIEW + username
        let currentdate = Date.init()
        let nowDay : String = formater.string(from: currentdate)
        let agoDay : String? = UserDefaults.standard.string(forKey: key) ?? ""
        
        if agoDay != nowDay {//不同一天
            UserDefaults.standard.setValue(nowDay, forKey: key)
            showAlert = false
        }
        return showAlert
    }

    private func reloadProfileChange() {
        let feed = environment.dataManager.userProfileManager.feedForCurrentUser()
        feed.refresh()
        feed.output.listenOnce(self, fireIfAlreadyLoaded: false) { result in
            if let newProf = result.value {
                print("手机绑定成功- \(newProf.phone ?? "")")
            }
            else {
                self.view.makeToast(Strings.Profile.unableToGet, duration: 0.8, position: CSToastPositionCenter)
            }
        }
    }
}

// For testing use only
extension EnrolledCoursesViewController {
    var t_loaded: OEXStream<()> {
        return self.enrollmentFeed.output.map {_ in
            return ()
        }
    }
}
