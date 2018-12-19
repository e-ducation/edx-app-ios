//
//  CourseCatalogDetailViewController.swift
//  edX
//
//  Created by Akiva Leffert on 12/3/15.
//  Copyright © 2015 edX. All rights reserved.
//

import WebKit
import UIKit

import edXCore

class CourseCatalogDetailViewController: UIViewController, InterfaceOrientationOverriding {
    private let courseID: String
    fileprivate var enrollmentFailureAlertView: UIAlertController?
    
    typealias Environment = OEXAnalyticsProvider & DataManagerProvider & NetworkManagerProvider & OEXRouterProvider & OEXStylesProvider & OEXConfigProvider
    
    private let environment: Environment
    private lazy var loadController = LoadStateViewController()
    fileprivate lazy var aboutView : CourseCatalogDetailView = {
        return CourseCatalogDetailView(frame: CGRect.zero, environment: self.environment)
    }()
    private let courseStream = BackedStream<(OEXCourse, enrolled: Bool)>()
    let alertView = TDVipAlertView()
    
    init(environment : Environment, courseID : String) {
        self.courseID = courseID
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = Strings.findCourses
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(aboutView)
        aboutView.snp.makeConstraints { make in
            make.edges.equalTo(safeEdges)
        }
        self.view.backgroundColor = OEXStyles.shared().standardBackgroundColor()
        
        self.loadController.setupInController(controller: self, contentView: aboutView)
        
        self.aboutView.setupInController(controller: self)
        
        self.aboutView.recomendView.checkButton.oex_addAction({ [weak self] (_) in
            self?.showVipViewcontroller()
        }, for: UIControlEvents.touchUpInside)
        
        listen()
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        environment.analytics.trackScreen(withName: OEXAnalyticsScreenCourseInfo)
    }
    
    private func listen() {
        self.courseStream.listen(self,
            success: {[weak self] (course, enrolled) in
                self?.aboutView.applyCourse(course: course)
                if enrolled {
                    self?.aboutView.actionText = Strings.CourseDetail.viewCourse
                    self?.aboutView.action = {completion in
                        if (self?.judgeEnrollCourseShowAlert(course: course))! {
                            self?.showVipBuyView()
                        }
                        else {
                            self?.showCourseScreen()
                        }
                        completion()
                    }
                }
                else if course.invitationOnly {
                    self?.aboutView.invitationOnlyText = Strings.CourseDetail.invitationOnly
                }
                else {
                    self?.aboutView.actionText = Strings.CourseDetail.enrollNow
                    self?.aboutView.action = {[weak self] completion in
                        if (self?.judgeNotEnrollCourseShowAlert(course: course))! { //显示VIP弹框
                            self?.showVipBuyView()
                            completion()
                        }
                        else {
                            if !course.can_free_enroll && course.is_subscribe_pay { //有价格，且不属于VIP免费的
                                self?.view.makeToast("移动端暂不支持，请至PC端完成购买", duration: 0.8, position: CSToastPositionCenter)
                            }
                            else {
                                self?.enrollInCourse(completion: completion)
                            }
                        }
                    }
                }
            }, failure: {[weak self] error in
                self?.loadController.state = LoadState.failed(error: error)
            }
        )
        self.aboutView.loaded.listen(self) {[weak self] _ in
            self?.loadController.state = .Loaded
        }
    }
    
    private func load() {
        let request = CourseCatalogAPI.getCourse(courseID: courseID)
        let courseStream = environment.networkManager.streamForRequest(request, persistResponse: true)
        let enrolledStream = environment.dataManager.enrollmentManager.streamForCourseWithID(courseID: courseID).resultMap {
            return Result.success($0.isSuccess)
        }
        let stream = joinStreams(courseStream, enrolledStream).map{($0, enrolled: $1) }
        self.courseStream.backWithStream(stream)
    }
    
    private func showCourseScreen(message: String? = nil) {
        self.environment.router?.showMyCourses(animated: true, pushingCourseWithID:courseID)
        
        if let message = message {
            
            let after = DispatchTime.now() + Double(Int64(EnrollmentShared.overlayMessageDelay * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: after) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: EnrollmentShared.successNotification), object: message)
            }
        }
    }
    
    func judgeEnrollCourseShowAlert(course :OEXCourse) -> (Bool) { //已加入的课程
        
        if course.is_normal_enroll { //普通购买
            return false
        }
        else {
            if course.has_cert || course.is_vip { //有证书 || VIP有效
                return false
            }
            return true
        }
    }
    
    func judgeNotEnrollCourseShowAlert(course :OEXCourse) -> (Bool) { //未加入的课程 是否显示VIP弹框
        if course.can_free_enroll { //可以免费加入
            return false
        }
        else {
            if course.is_subscribe_pay && course.is_vip { //会员免费加入
                return false
            }
            return true
        }
    }
    
    func showVipBuyView() { //显示VIP购买
        
        alertView.sureButton.addTarget(self, action: #selector(sureButtonAction), for: .touchUpInside)
        let view = UIApplication.shared.keyWindow?.rootViewController?.view
        view?.addSubview(alertView)
        
        alertView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(view!)
        }
    }
    
    func sureButtonAction() {
        alertView.removeFromSuperview()
        let packageVC = TDVipPackageViewController()
        self.navigationController?.pushViewController(packageVC, animated: true)
    }
    
    func judgeFindCourse(course :OEXCourse) -> Bool {
        if course.is_subscribe_pay  { //属于VIP免费课程
            if course.is_vip { //会员有效
                return true
            }
            else {
               return false
            }
        }
        else {
            return false
        }
    }
    
    fileprivate func enrollInCourse(completion : @escaping () -> Void) {
        
        environment.analytics.trackCourseEnrollment(courseId: self.courseID, name: AnalyticsEventName.CourseEnrollmentClicked.rawValue, displayName: AnalyticsDisplayName.EnrolledCourseClicked.rawValue)
        
        let notEnrolled = environment.dataManager.enrollmentManager.enrolledCourseWithID(courseID: self.courseID) == nil
        
        guard notEnrolled else {
            self.showCourseScreen(message: Strings.findCoursesAlreadyEnrolledMessage)
            completion()
            return
        }
        
        let courseID = self.courseID
        let request = CourseCatalogAPI.enroll(courseID: courseID)
        environment.networkManager.taskForRequest(request) {[weak self] response in
            if response.response?.httpStatusCode.is2xx ?? false {
                self?.environment.analytics.trackCourseEnrollment(courseId:courseID, name: AnalyticsEventName.CourseEnrollmentSuccess.rawValue, displayName: AnalyticsDisplayName.EnrolledCourseSuccess.rawValue)
                self?.showCourseScreen(message: Strings.findCoursesEnrollmentSuccessfulMessage)
            }
            else if response.response?.httpStatusCode.is4xx ?? false {
                self?.showCourseEnrollmentFailureAlert()
            }
            else {
                self?.showOverlay(withMessage: Strings.findCoursesEnrollmentErrorDescription)
            }
            completion()
        }
    }
    
    func showCourseEnrollmentFailureAlert() {
        enrollmentFailureAlertView = UIAlertController().showAlert(withTitle: Strings.findCoursesEnrollmentErrorTitle, message: Strings.findCoursesUnableToEnrollErrorDescription(platformName: environment.config.platformName()), cancelButtonTitle: Strings.ok, onViewController: self)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    func showVipViewcontroller() {
        let vipVC = TDVipPackageViewController()
        self.navigationController?.pushViewController(vipVC, animated: true)
    }
}
// Testing only
extension CourseCatalogDetailViewController {
    
    var t_loaded : OEXStream<()> {
        return self.aboutView.loaded
    }
    
    var t_actionText: String? {
        return self.aboutView.actionText
    }
    
    func t_enrollInCourse(completion : @escaping () -> Void) {
        enrollInCourse(completion: completion)
    }
    
    func t_isShowingAlertView() -> Bool{
        return enrollmentFailureAlertView?.visible ?? false
    }
}
