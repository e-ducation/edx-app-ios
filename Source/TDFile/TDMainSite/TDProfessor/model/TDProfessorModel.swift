//
//  TDProfessorModel.swift
//  edX
//
//  Created by Elite Edu on 2019/4/18.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

public class TDProfessorModel {

    enum ProfessorKeys: String, RawStringExtractable {
        case Id = "id"
        case UserId = "user_id"
        case Name = "name"
        case Description = "description"
        case Avatar = "avatar"
    }
    
    var id: Int?
    var user_id: Int?
    var name: String?
    var description: String?
    var avatar: String?
    
    public init?(dict: Dictionary<String, Any>) {
        
        id = dict[ProfessorKeys.Id] as? Int
        user_id = dict[ProfessorKeys.UserId] as? Int
        name = dict[ProfessorKeys.Name] as? String
        description = dict[ProfessorKeys.Description] as? String
        avatar = dict[ProfessorKeys.Avatar] as? String
    }
}
