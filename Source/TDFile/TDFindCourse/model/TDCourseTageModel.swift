//
//  TDCourseTageModel.swift
//  edX
//
//  Created by Elite Edu on 2019/7/17.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

class TDCourseTageModel: NSObject {
    
    enum CourseTagKeys: String, RawStringExtractable {
        case TagId = "id"
        case TagName = "subject_name"
    }
    
    var id: Int?
    var tagName: String?
    
    public init?(dict: Dictionary<String,Any>) {
        id = dict[CourseTagKeys.TagId] as? Int
        tagName = dict[CourseTagKeys.TagName] as? String
    }
    
}
