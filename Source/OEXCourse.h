//
//  OEXCourse.h
//  edXVideoLocker
//
//  Created by Rahul Varma on 05/06/14.
//  Copyright (c) 2014-2015 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CourseMediaInfo;
@class OEXLatestUpdates;
@class OEXCoursewareAccess;
@class CourseShareUtmParameters;

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, OEXStartType) {
    OEXStartTypeString,
    OEXStartTypeTimestamp,
    OEXStartTypeNone
};

NSString* NSStringForOEXStartType(OEXStartType type);
OEXStartType OEXStartTypeForString(NSString* type);

@interface OEXCourseStartDisplayInfo : NSObject

- (id)initWithDate:(nullable NSDate*)date displayDate:(nullable NSString*)displayDate type:(OEXStartType)type;

@property (readonly, nonatomic, strong, nullable) NSDate* date;
@property (readonly, copy, nonatomic, nullable) NSString* displayDate;
@property (readonly, assign, nonatomic) OEXStartType type;

@property (readonly, nonatomic) NSDictionary<NSString*, id>* jsonFields;

@end


@interface OEXCourse : NSObject

- (id)initWithDictionary:(NSDictionary*)info;
// TODO: Rename these to CamelCase (MK - eh just make this swift)
@property (readonly, nonatomic, strong, nullable) OEXLatestUpdates* latest_updates;
@property (readonly, nonatomic, strong, nullable) NSDate* end;
@property (readonly, nonatomic, strong) OEXCourseStartDisplayInfo* start_display_info;
@property (readonly, nonatomic, copy, nullable) NSString* name;
@property (readonly, nonatomic, copy, nullable) NSString* org;
@property (readonly, nonatomic, copy, nullable) NSString* video_outline;
@property (readonly, nonatomic, copy, nullable) NSString* effort;
@property (readonly, nonatomic, copy, nullable) NSString* course_id;
@property (readonly, nonatomic, copy, nullable) NSString* root_block_usage_key;
@property (readonly, nonatomic, copy, nullable) NSString* subscription_id;
@property (readonly, nonatomic, copy, nullable) NSString* number;
@property (readonly, nonatomic, copy, nullable) NSString* overview_html;
@property (readonly, nonatomic, copy, nullable) NSString* short_description;
@property (readonly, nonatomic, copy, nullable) NSString* course_updates;         //  ANNOUNCEMENTS URL
@property (readonly, nonatomic, copy, nullable) NSString* course_handouts;        //  HANDOUTS URL
@property (readonly, nonatomic, copy, nullable) NSString* course_about;           // COURSE INFO URL
@property (readonly, nonatomic) Boolean invitationOnly;
@property (readonly, nonatomic, strong, nullable) OEXCoursewareAccess* courseware_access;
@property (readonly, nonatomic, copy, nullable) NSString* discussionUrl;
@property (readonly, nonatomic, copy, nullable) NSDictionary<NSString*, CourseMediaInfo*>* mediaInfo;
@property (readonly, nonatomic, strong, nullable) CourseMediaInfo* courseImageMediaInfo;
@property (readonly, nonatomic, strong, nullable) CourseMediaInfo* courseVideoMediaInfo;
@property (nonatomic, readonly) CourseShareUtmParameters *courseShareUtmParams;
@property (readonly, nonatomic, assign) BOOL isStartDateOld;
@property (readonly, nonatomic, assign) BOOL isEndDateOld;

@property (readonly, nonatomic, assign) BOOL is_vip; //是否VIP
@property (readonly, nonatomic, assign) BOOL is_normal_enroll; //是普通加入，还是VIP期间免费加入
@property (readonly, nonatomic, assign) BOOL has_cert; //已获取证书
@property (readonly, nonatomic, assign) BOOL is_enroll; //已加入
@property (readonly, nonatomic, assign) BOOL is_subscribe_pay; //属于VIP免费课程？
@property (readonly, nonatomic, assign) BOOL can_free_enroll; //可以免费加入(不是VIP情况下)
@property (readonly, nonatomic, strong) NSDictionary *recommended_package; //推荐VIP

@property (readonly, nonatomic, strong, nullable) NSString* courseImageURL;


@end


NS_ASSUME_NONNULL_END

