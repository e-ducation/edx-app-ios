//
//  TDFindCourseCell.swift
//  edX
//
//  Created by Elite Edu on 2019/7/17.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDFindCourseCell: UITableViewCell {

    fileprivate static let cellIdentifier = "TDFindCourseCell"
    
    let bgView = UIView()
    let courseImage = UIImageView()
    let courseTitle = UILabel()
    let timeLabel = UILabel()
    let professorLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configeView()
        setViewConstraint()
    }
    
    var model : OEXCourse? {
        didSet {
            courseTitle.text = model?.name
            if let imageUrl = model?.courseImageURL, let hostUrl = OEXConfig.shared().apiHostURL()?.absoluteString {
                let url = hostUrl + imageUrl
                let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                courseImage.sd_setImage(with: URL(string: urlEncoding ?? url), placeholderImage: UIImage(named: "main_recomend_6"))
            }
           
            if let professor = model?.professor_name {
                professorLabel.text = Strings.professorText + professor
            }
           
            if let isStarted = model?.isStartDateOld, isStarted == true {
                timeLabel.text = Strings.onCourse
            }
            else {
                if let date = model?.start_display_info.date {
                let formattedStartDate = DateFormatting.getDateString(withFormat: "yyyy-MM-dd", date: date as Date)
                timeLabel.text = Strings.Course.starting(startDate: formattedStartDate ?? "" )
                }
                else if let display = model?.start_display_info.displayDate {
                    timeLabel.text = Strings.Course.starting(startDate: display)
                }
            }
        }
    }
    
    func configeView() {
        
        bgView.backgroundColor = UIColor.white
        
        courseImage.layer.masksToBounds = true
        courseImage.layer.cornerRadius = 4.0
        
        courseTitle.textColor = UIColor.init(hexString: "#2e313c")
        courseTitle.font = UIFont(name: "PingFang-SC-Medium", size: 16)
        courseTitle.numberOfLines = 2
        
        timeLabel.textColor = UIColor.init(hexString: "#0f80bf")
        timeLabel.font = UIFont(name: "PingFangSC-Regular", size: 12)
        
        professorLabel.textColor = UIColor.init(hexString: "#656d78")
        professorLabel.font = UIFont(name: "PingFangSC-Regular", size: 12)
        
        courseImage.image = UIImage(named: "main_recomend_6")
        courseTitle.text = "国际商法：美国商业法律制度环境文案文案文案文案文案美国商业法律制度环境文案文案文案文案文案文案美国商业法律制度环境文案文案文案文案文案文案"
        timeLabel.text = "最近：2019-06-14"
        professorLabel.text = Strings.professorText
        
        contentView.addSubview(bgView)
        bgView.addSubview(courseImage)
        bgView.addSubview(courseTitle)
        bgView.addSubview(timeLabel)
        bgView.addSubview(professorLabel)
    }
    
    func setViewConstraint() {
        
        bgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(contentView)
        }
        
        courseImage.snp.makeConstraints { (make) in
            make.left.equalTo(bgView).offset(12)
            make.centerY.equalTo(bgView)
            make.size.equalTo(CGSize(width: 160, height: 90))
        }
        
        courseTitle.snp.makeConstraints { (make) in
            make.left.equalTo(courseImage.snp_right).offset(8)
            make.top.equalTo(courseImage)
            make.right.equalTo(bgView).offset(-11)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(courseTitle)
            make.bottom.equalTo(courseImage)
            make.height.equalTo(18)
        }
        
        professorLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(courseTitle)
            make.bottom.equalTo(timeLabel.snp.top).offset(-6)
            make.height.equalTo(18)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
