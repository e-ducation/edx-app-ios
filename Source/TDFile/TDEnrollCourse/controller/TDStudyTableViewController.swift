//
//  TDStudyTableViewController.swift
//  edX
//
//  Created by Elite Edu on 2019/7/16.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDStudyCourseCell : UITableViewCell {
    static let margin = StandardVerticalMargin
    
    fileprivate static let cellIdentifier = "TDStudyCourseCell"
    
    let shadowView = UIView()
    let bgView = UIView()
    let courseImage = UIImageView()
    let courseTitle = UILabel()
    let timeLabel = UILabel()
    let progressLabel = UILabel()
    let progressView = UIProgressView()
    
    let vipExpiredView = TDVipExpiredView()
    
    private let courseCardBorderStyle = BorderStyle()
    private let iPadHorizMargin:CGFloat = 18//180
    
    override init(style : UITableViewCell.CellStyle, reuseIdentifier : String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.white
        selectionStyle = .none
        
        configeView()
        setViewConstraint()

    }
    
    func setStudyCellData(course : OEXCourse) {
        //VIP权利加入 + VIP过期 + 没取得证书
        if course.is_normal_enroll == false && course.is_vip == false && course.has_cert == false {
            vipExpiredView.isHidden = false
        }
        else {
            vipExpiredView.isHidden = true
        }
        
        courseTitle.text = course.name
        if let imageUrl = course.courseImageURL, let hostUrl = OEXConfig.shared().apiHostURL()?.absoluteString {
            let url = hostUrl + imageUrl
            let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            courseImage.sd_setImage(with: URL(string:urlEncoding ?? url), placeholderImage: UIImage(named: "main_recomend_6"))
        }
        
        progressLabel.text = String(format: "%.0f%%", course.studyProgres*100)
        progressView.tintColor = UIColor(hexString: course.studyPass == true ? "#8cc34a" : "#4788c7")
        progressView.progress = course.studyProgres
    }
    
    func configeView() {
        
        shadowView.backgroundColor = UIColor.white.withAlphaComponent(0)
        shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView.layer.shadowRadius = 4.0
        
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 4.0
        bgView.layer.backgroundColor = UIColor.white.cgColor
        
        courseImage.layer.masksToBounds = true
        courseImage.layer.cornerRadius = 4.0
        
        vipExpiredView.applyBorderStyle(style: courseCardBorderStyle)
        
        courseTitle.textColor = UIColor.init(hexString: "#2e313c")
        courseTitle.font = UIFont(name: "PingFang-SC-Medium", size: 14)
        courseTitle.numberOfLines = 2
        
        timeLabel.textColor = UIColor.init(hexString: "#656d78")
        timeLabel.font = UIFont(name: "PingFangSC-Regular", size: 12)
        
        progressLabel.textColor = UIColor.init(hexString: "#656d78")
        progressLabel.font = UIFont(name: "PingFangSC-Regular", size: 12)
        
        progressView.progress = 0.0
        progressView.trackTintColor = UIColor(hexString: "#d8d8d8")
        progressView.tintColor = UIColor(hexString: "#4788c7")
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = 2.0
        
        courseImage.image = UIImage(named: "main_recomend_6")
        courseTitle.text = "课程名称"
        timeLabel.text = ""
        progressLabel.text = "0%"
        
        
        contentView.addSubview(shadowView)
        shadowView.addSubview(bgView)
        bgView.addSubview(courseImage)
        bgView.addSubview(vipExpiredView)
        bgView.addSubview(courseTitle)
        bgView.addSubview(timeLabel)
        bgView.addSubview(progressLabel)
        bgView.addSubview(progressView)
        
    }
    
    func setViewConstraint() {
        
        shadowView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(10)
            make.right.equalTo(contentView).offset(-10)
            make.top.equalTo(contentView).offset(6)
            make.bottom.equalTo(contentView).offset(-6)
        }
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(shadowView)
        }
        
        courseImage.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(10)
            make.centerY.equalTo(bgView)
            make.size.equalTo(CGSize(width: 126, height: 72))
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(courseImage.snp.right).offset(8)
            make.bottom.equalTo(courseImage)
            make.size.equalTo(CGSize(width: 108, height: 18))
        }
        
        progressView.snp.makeConstraints { (make) in
            make.right.equalTo(bgView).offset(-9)
            make.bottom.equalTo(courseImage).offset(-7)
            make.size.equalTo(CGSize(width: 58, height: 4))
        }
        
        progressLabel.snp.makeConstraints { (make) in
            make.right.equalTo(progressView.snp.left).offset(-5)
            make.centerY.equalTo(progressView)
            make.height.equalTo(18)
        }
    
        courseTitle.snp.makeConstraints { (make) in
            make.left.equalTo(timeLabel)
            make.top.equalTo(courseImage)
            make.right.equalTo(bgView).offset(-5)
        }
        
        vipExpiredView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalTo(courseImage)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc protocol TDStudyTableViewControllerDelegate {
    func coursesTableChoseCourse(course : OEXCourse)//选择课程
    func clickExpiredButton() //vip重置
    func havardCourseEnter() //哈商
    func gotoFindCourse() //去选课
}

class TDStudyTableViewController: UITableViewController {
    
    enum Context {
        case CourseCatalog
        case EnrollmentList
    }
    
    typealias Environment = NetworkManagerProvider
    
    private let environment : Environment
    private let context: Context
    
    weak var delegate : TDStudyTableViewControllerDelegate?
    var courses : [OEXCourse] = []
    var dateStr: String = ""
    var days: Int = 0
    
    init(environment : Environment, context: Context) {
        self.context = context
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.white
        
        self.tableView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(self.view)
        }
        
        tableView.register(TDStudyCourseCell.self, forCellReuseIdentifier: TDStudyCourseCell.cellIdentifier)
        tableView.register(TDHavardCell.self, forCellReuseIdentifier: TDHavardCell.cellIdentifier)
        tableView.register(TDStudyNonCell.self, forCellReuseIdentifier: TDStudyNonCell.cellIdentifier)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return days > 0 ? 1 : 0
        }
        
        if self.courses.count == 0 {
            return 1
        }
        return self.courses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TDHavardCell.cellIdentifier, for: indexPath as IndexPath) as! TDHavardCell
            cell.dateStr = dateStr
            return cell
        }
        
        if self.courses.count == 0  {
            let cell = tableView.dequeueReusableCell(withIdentifier: TDStudyNonCell.cellIdentifier, for: indexPath as IndexPath) as! TDStudyNonCell
            cell.dataNonCell(message: Strings.noAddCourse, iconStr: "course_non_image", buttonStr: Strings.addCourses)
            cell.findButton.oex_addAction({ [weak self] (action) in
                self?.delegate?.gotoFindCourse()
            }, for: .touchUpInside)
            return cell
        }
        
        let course = self.courses[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: TDStudyCourseCell.cellIdentifier, for: indexPath as IndexPath) as! TDStudyCourseCell
        
        cell.setStudyCellData(course: course)
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 160
        }
        
        if self.courses.count == 0  {
            return 325
        }
        return 102
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            self.delegate?.havardCourseEnter()
            return;
        }
        
        if self.courses.count == 0  {
            return;
        }
        
        let course = self.courses[indexPath.row]
        //VIP权利加入 + VIP过期 + 没取得证书
        if course.is_normal_enroll == false && course.is_vip == false && course.has_cert == false {
            self.delegate?.clickExpiredButton()
        }
        else {
            self.delegate?.coursesTableChoseCourse(course: course)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        let label = UILabel()
        label.font = UIFont(name: "PingFang-SC-Medium", size: 18)
        label.textColor = UIColor(hexString: "#434343")
        label.text = Strings.studyProgress
        view.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(view)
            make.left.equalTo(view).offset(14)
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 48
    }
}

