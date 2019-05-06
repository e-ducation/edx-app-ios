//
//  OEXNetworkConstants.h
//  edXVideoLocker
//
//  Created by Nirbhay Agarwal on 22/05/14.
//  Copyright (c) 2014 edX. All rights reserved.
//

#ifndef edXVideoLocker_NetworkConstants_h
#define edXVideoLocker_NetworkConstants_h

//NSNotification center constants
#define DOWNLOAD_PROGRESS_NOTIFICATION @"downloadProgressNotification"
#define DOWNLOAD_PROGRESS_NOTIFICATION_TASK @"downloadProgressNotificationTask"
#define DOWNLOAD_PROGRESS_NOTIFICATION_TOTAL_BYTES_WRITTEN @"downloadProgressNotificationTotalBytesWritten"
#define DOWNLOAD_PROGRESS_NOTIFICATION_TOTAL_BYTES_TO_WRITE @"downloadProgressNotificationTotalBytesToWrite"

#define REQUEST_USER_DETAILS @"User details"
#define REQUEST_COURSE_ENROLLMENTS @"Courses user has enrolled in"

// edX Constants

// Extensions must be lowercase
#define VIDEO_URL_EXTENSION_OPTIONS @[ @".mp4", @".m3u8" ]
#define ONLINE_ONLY_VIDEO_URL_EXTENSIONS @[ @".m3u8" ]

#define URL_EXCHANGE_TOKEN @"/oauth2/exchange_access_token/{backend}/"
#define URL_USER_DETAILS @"/api/v1/mobile"// /api/mobile/v0.5/users
#define URL_COURSE_ENROLLMENTS @"/course_enrollments/"
#define URL_COURSE_HANDOUTS @"/handouts"
#define URL_COURSE_ANNOUNCEMENTS @"/updates"
#define URL_RESET_PASSWORD  @"/password_reset/"
#define URL_SUBSTRING_VIDEOS @"edx-course-videos"
#define URL_SUBSTRING_ASSETS @"asset/"
#define AUTHORIZATION_URL @"/oauth2/access_token"
#define URL_GET_USER_INFO @"/api/mobile/v0.5/my_user_info"
#define URL_COURSE_ENROLLMENT @"/api/enrollment/v1/enrollment"
#define URL_COURSE_ENROLLMENT_EMAIL_OPT_IN @"/api/user_api/v1/preferences/email_opt_in"
#define SIGN_UP_URL @"/user_api/v1/account/registration/"

#define VIP_INFO_URL @"/api/v1/mobile/vip/package/vip_info"//会员VIP信息和套餐列表
#define VIP_CTEATE_ALIPAY_ORDER @"/api/v1/mobile/vip/pay/alipay/paying/" //创建VIP支付宝订单
#define VIP_CTEATE_WECHAT_ORDER @"/api/v1/mobile/vip/pay/wechat/paying/" //创建VIP微信订单
#define VIP_ORDER_STATUS_URL @"/api/v1/vip/order/" //VIP订单状态
#define APP_APPROVE_STATUS_URL @"/api/mobile/v0.5/app_version/last/"//App是否审核中
#define VIP_CTEATE_INPURCHASE_ORDER @"/api/v1/mobile/vip/pay/apple/inapp_purchase/"//创建VIP内购订单
#define APP_PURCHASE_VERIFY_URL @"/api/v1/mobile/vip/pay/apple/receipt_verify/" //App Store内购验证
#define APP_BINDPHONE_CODE_URL @"/api/user/v1/accounts/send_code_binding_phone/" //发送验证码
#define APP_BINGPHONE_URL @"/api/user/v1/accounts/binding_phone/" //绑定手机
#define APP_PASSWORD_RESET @"/api/user/v1/accounts/elite_password_reset/" //重置密码
#define App_MAIN_SITE_URL @"/api/v2/pages/find/" //主站接口
#define APP_ARTICLE_TAGS_URL @"/api/v2/tags/"//文章标签
#define APP_ARTICLE_LIST_URL @"/api/v2/app/"//文章列表
#define APP_PROFESSOR_LIST_URL @"/api/v1/professors/"//教授列表

#endif
