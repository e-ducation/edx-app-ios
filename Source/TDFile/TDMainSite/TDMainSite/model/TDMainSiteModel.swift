//
//  TDMainSiteModel.swift
//  edX
//
//  Created by Elite Edu on 2019/4/19.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDMainSiteBannerModel: NSObject {
    enum MainSiteBannerKeys: String, RawStringExtractable {
        
        case Link = "link"
        case MobileImage = "mobile_image"
    }
    
    let link: String?
    let mobile_image: String?
    
    init(dic: Dictionary<String, Any>) {
        link = dic[MainSiteBannerKeys.Link] as? String
        
        if let host = OEXConfig.shared().apiHostURL()?.absoluteString,
           let imagelink = dic[MainSiteBannerKeys.MobileImage] as? String {
            mobile_image = host + imagelink
        }
        else {
            mobile_image = ""
        }
    }
}

class TDMainSiteCategoryModel: NSObject {
    enum MainSiteCategoryKeys: String, RawStringExtractable {
        
        case CategoriesLink = "categories_link"
        case CategoriesName = "categories_name"
        case ImgForApp = "img_for_app"
        
    }
    
    let categories_link: String?
    let categories_name: String?
    let img_for_app: String?
    
    init(dic: Dictionary<String, Any>) {
        categories_link = dic[MainSiteCategoryKeys.CategoriesLink] as? String
        categories_name = dic[MainSiteCategoryKeys.CategoriesName] as? String
        
        if let host = OEXConfig.shared().apiHostURL()?.absoluteString,
            let imagelink = dic[MainSiteCategoryKeys.ImgForApp] as? String {
            img_for_app = host + imagelink
        }
        else {
            img_for_app = ""
        }
    }
}

class TDMainSiteCourseModel: NSObject {
    enum MainSiteCourseKeys: String, RawStringExtractable {
        
        case Description = "description"
        case Link = "link"
        case Title = "title"
        case Image = "image"
        case PageUrl = "publicity_page_url"
    }
    
    let descript: String?
    let link: String?
    let title: String?
    let image: String?
    let pageUrl: String?
    
    init(dic: Dictionary<String, Any>) {
        descript = dic[MainSiteCourseKeys.Description] as? String
        link = dic[MainSiteCourseKeys.Link] as? String
        title = dic[MainSiteCourseKeys.Title] as? String
        pageUrl = dic[MainSiteCourseKeys.PageUrl] as? String
        
        if let host = OEXConfig.shared().apiHostURL()?.absoluteString,
            let imagelink = dic[MainSiteCourseKeys.Image] as? String {
            image = host + imagelink
        }
        else {
            image = ""
        }
    }
}

class TDMainSiteProfessorModel: NSObject {
    enum MainSiteProfessorKeys: String, RawStringExtractable {
        
        case ProfessorLink = "professor_link"
        case Name = "name"
        case Content = "content"
        case ProfessorPic = "professor_pic"
    }
    
    let professor_link: String?
    let name: String?
    let content: String?
    let professor_pic: String?
    
    init(dic: Dictionary<String, Any>) {
        professor_link = dic[MainSiteProfessorKeys.ProfessorLink] as? String
        name = dic[MainSiteProfessorKeys.Name] as? String
        content = dic[MainSiteProfessorKeys.Content] as? String
        
        if let host = OEXConfig.shared().apiHostURL()?.absoluteString,
            let imagelink = dic[MainSiteProfessorKeys.ProfessorPic] as? String {
            professor_pic = host + imagelink
        }
        else {
            professor_pic = ""
        }
    }
}

class TDMainSiteStoryModel: NSObject {
    enum MainSiteStoryKeys: String, RawStringExtractable {
        
        case StoryLink = "story_link"
        case StoryTitle = "story_title"
        case StoryContent = "story_content"
        case PhotoLocation = "photo_location"
        case StoryPhoto = "story_photo"
    }
    
    let story_link: String?
    let story_title: String?
    let story_content: String?
    let photo_location: String? //left 为3张图的用户故事，center 是一张图的用户故事
    var story_photo: Array<String>?
    
    init(dic: Dictionary<String, Any>) {
        story_link = dic[MainSiteStoryKeys.StoryLink] as? String
        story_title = dic[MainSiteStoryKeys.StoryTitle] as? String
        story_content = dic[MainSiteStoryKeys.StoryContent] as? String
        photo_location = dic[MainSiteStoryKeys.PhotoLocation] as? String
        story_photo = dic[MainSiteStoryKeys.StoryPhoto] as? [String]
    }
}


class TDMainSiteModel: NSObject {
    
    enum MainSiteTypeKeys: String, RawStringExtractable {
        case Banner = "Banner" //轮播图
        case CategoriesListBlock = "CategoriesListBlock" //分类
        case SeriesCourse = "SeriesCourse" //精选课程
        case RecommendCourse = "RecommendCourse" //推荐课程
        case ProfessorBlock = "ProfessorBlock" //推荐教授
        case StoryBlock = "StoryBlock" //用户股市
        case OtherImgBlock = "OtherImgBlock" //其他
    }
    
    enum MainSiteKeys: String, RawStringExtractable {
        
        case Body = "body"
        case Title = "title"
        case DataType = "type"
        case Value = "value"
        case Banners = "banners"
        case LoopTime = "loop_time"
        case Categorieslist = "categorieslist"
        case Series = "series"
        case Courses = "courses"
        case Professor = "professor"
        case Story = "story"
        case VipImage = "img_for_MOBILE"
    }
    
    let title: String?
    var bannerArray = Array<TDMainSiteBannerModel>()
    var loop_time: Int?
    var categoryArray = Array<TDMainSiteCategoryModel>()
    var seriesArray = Array<TDMainSiteCourseModel>()
    var courseArray = Array<TDMainSiteCourseModel>()
    var professorArray = Array<TDMainSiteProfessorModel>()
    var storyImgArray = Array<TDMainSiteStoryModel>()
    var storyArray = Array<TDMainSiteStoryModel>()
    var vipImageUrl: String?
    var categoryTitle: String?
    var seriesTitle: String?
    var courseTitle: String?
    var professorTitle: String?
    var storyTitle: String?
    
    public init?(dic: Dictionary<String, Any>) {
        
        title = dic[MainSiteKeys.Title] as? String
        
        let results = dic[MainSiteKeys.Body] as! Array<Dictionary<String, Any>>
        if results.count > 0 {
            for dic in results {
                if let type = dic[MainSiteKeys.DataType] as? String, type.count > 0 {
                    if type == MainSiteTypeKeys.Banner.rawValue {
                        let valueDic = dic[MainSiteKeys.Value] as! Dictionary<String, Any>
                        loop_time = valueDic[MainSiteKeys.LoopTime] as? Int
                        
                        let array = valueDic[MainSiteKeys.Banners] as! Array<Dictionary<String, Any>>
                        if array.count > 0 {
                            for bannerDic in array {
                                let bannerModel = TDMainSiteBannerModel(dic: bannerDic)
                                bannerArray.append(bannerModel)
                            }
                        }
                    }
                    else if type == MainSiteTypeKeys.CategoriesListBlock.rawValue {
                        let valueDic = dic[MainSiteKeys.Value] as! Dictionary<String, Any>
                        categoryTitle = valueDic[MainSiteKeys.Title] as? String
                        
                        let array = valueDic[MainSiteKeys.Categorieslist] as! Array<Dictionary<String, Any>>
                        if array.count > 0 {
                            for bannerDic in array {
                                let bannerModel = TDMainSiteCategoryModel(dic: bannerDic)
                                categoryArray.append(bannerModel)
                            }
                        }
                    }
                    else if type == MainSiteTypeKeys.SeriesCourse.rawValue {
                        let valueDic = dic[MainSiteKeys.Value] as! Dictionary<String, Any>
                        seriesTitle = valueDic[MainSiteKeys.Title] as? String
                        
                        let array = valueDic[MainSiteKeys.Series] as! Array<Dictionary<String, Any>>
                        if array.count > 0 {
                            for bannerDic in array {
                                let bannerModel = TDMainSiteCourseModel(dic: bannerDic)
                                seriesArray.append(bannerModel)
                            }
                        }
                    }
                    else if type == MainSiteTypeKeys.RecommendCourse.rawValue {
                        let valueDic = dic[MainSiteKeys.Value] as! Dictionary<String, Any>
                        courseTitle = valueDic[MainSiteKeys.Title] as? String
                        
                        let array = valueDic[MainSiteKeys.Courses] as! Array<Dictionary<String, Any>>
                        if array.count > 0 {
                            for bannerDic in array {
                                let bannerModel = TDMainSiteCourseModel(dic: bannerDic)
                                courseArray.append(bannerModel)
                            }
                        }
                    }
                    else if type == MainSiteTypeKeys.ProfessorBlock.rawValue {
                        let valueDic = dic[MainSiteKeys.Value] as! Dictionary<String, Any>
                        professorTitle = valueDic[MainSiteKeys.Title] as? String
                        
                        let array = valueDic[MainSiteKeys.Professor] as! Array<Dictionary<String, Any>>
                        if array.count > 0 {
                            for bannerDic in array {
                                let bannerModel = TDMainSiteProfessorModel(dic: bannerDic)
                                professorArray.append(bannerModel)
                            }
                        }
                    }
                    else if type == MainSiteTypeKeys.StoryBlock.rawValue {
                        let valueDic = dic[MainSiteKeys.Value] as! Dictionary<String, Any>
                        storyTitle = valueDic[MainSiteKeys.Title] as? String
                        
                        let array = valueDic[MainSiteKeys.Story] as! Array<Dictionary<String, Any>>
                        if array.count > 0 {
                            for bannerDic in array {
                                let bannerModel = TDMainSiteStoryModel(dic: bannerDic)
                                if bannerModel.photo_location == "left" {
                                    storyImgArray.append(bannerModel)
                                }
                                else {
                                    storyArray.append(bannerModel)
                                } 
                            }
                        }
                    }
                    else if type == MainSiteTypeKeys.OtherImgBlock.rawValue {
                        let valueDic = dic[MainSiteKeys.Value] as! Dictionary<String, Any>
                        if let host = OEXConfig.shared().apiHostURL()?.absoluteString,
                            let imagelink = valueDic[MainSiteKeys.VipImage] as? String {
                            vipImageUrl = host + imagelink
                        }
                        else {
                            vipImageUrl = ""
                        }
                    }
                }
            }
        }
    }
}
