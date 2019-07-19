//
//  TDFindCourseModel.swift
//  edX
//
//  Created by Elite Edu on 2019/7/17.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class FindCourseImageModel: NSObject {
    enum ImageKeys: String, RawStringExtractable {
        case Raw = "raw"
        case Small = "small"
        case Large = "large"
    }

    var raw: String?
    var small: String?
    var large: String?

    init(dict: Dictionary<String, Any>) {
        raw = dict[ImageKeys.Raw] as? String
        small = dict[ImageKeys.Small] as? String
        large = dict[ImageKeys.Large] as? String
    }
}

class TDFindCourseModel: NSObject {

    enum FindCourseKeys: String, RawStringExtractable {
        case CourseId = "id"
        case CourseName = "name"
        case CourseMedia = "media"
        case ProfessorName = "professor_name"
        case CourseDate = "start"
        case DisplayDate = "start_display"
        case CourseImage = "image"
    }
    
    var courseID: Int?
    var courseName: String?
    var professorName: String?
    var courseDate: String?
    var displayDate: String?
    var imageModel: FindCourseImageModel?
    
    public init?(dict: Dictionary<String,Any>) {
        courseID = dict[FindCourseKeys.CourseId] as? Int
        courseName = dict[FindCourseKeys.CourseName] as? String
        professorName = dict[FindCourseKeys.ProfessorName] as? String
        courseDate = dict[FindCourseKeys.CourseDate] as? String
        displayDate = dict[FindCourseKeys.DisplayDate] as? String
        
        let mediaDic = dict[FindCourseKeys.CourseMedia] as? Dictionary<String, Any>
        if let imageDic = mediaDic?[FindCourseKeys.CourseImage] as? Dictionary<String, Any> {
            imageModel = FindCourseImageModel(dict: imageDic)
        }
    }
}
