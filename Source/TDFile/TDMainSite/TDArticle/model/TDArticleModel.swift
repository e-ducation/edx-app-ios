//
//  TDArticleModel.swift
//  edX
//
//  Created by Elite Edu on 2019/4/18.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

class TDArticleModel: NSObject {

    enum ArticleKeys: String, RawStringExtractable {
        case Id = "id"
        case Title = "title"
        case DateTime = "article_datetime"
        case LikeCount = "liked_count"
        case Tags = "tags"
        case Article_Image = "article_cover_app"
        case DownloadUrl = "download_url"
        case Meta = "meta"
        case HtmlUrl = "html_url"
    }
    
    var id: Int?
    var title: String?
    var article_datetime: String?
    var liked_count: Int?
    var tags: Array<String>?
    var article_image: Dictionary<String, Any>?
    var articleImageStr: String?
    var meta: Dictionary<String, Any>?
    var html_url: String?
    
    public init?(dict: Dictionary<String, Any>) {
        
        id = dict[ArticleKeys.Id] as? Int
        title = dict[ArticleKeys.Title] as? String
        article_datetime = dict[ArticleKeys.DateTime] as? String
        liked_count = dict[ArticleKeys.LikeCount] as? Int
        tags = dict[ArticleKeys.Tags] as? Array
        
        article_image = dict[ArticleKeys.Article_Image] as? Dictionary
        if let imageDic = article_image {
            let dic: [String: String] = imageDic[ArticleKeys.Meta] as! [String : String]
            
            if let host = OEXConfig.shared().apiHostURL()?.absoluteString,
                let imagelink = dic[ArticleKeys.DownloadUrl] {
                articleImageStr = host + imagelink
            }
            else {
                articleImageStr = ""
            }
        }
        
        meta = dict[ArticleKeys.Meta] as? Dictionary<String, Any>
        if let metaDic = meta {
            html_url = metaDic[ArticleKeys.HtmlUrl] as? String
        }
    }
}
