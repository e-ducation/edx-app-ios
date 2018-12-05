//
//  TDQQManager.h
//  TDThirdLogin
//
//  Created by Elite Edu on 2018/11/9.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TDQQAuthHandler)(NSString *token,NSString *openid,NSError *error);
typedef void (^TDQQUserinfo)(NSDictionary *userProfile,NSError *error);

@interface TDQQManager : NSObject

+ (instancetype)shareManager;

- (void)qqAuthenLogin:(TDQQAuthHandler)compleHandler; //登录
- (BOOL)isQQInstalled; //是否安装qq

- (BOOL)handleOpenURL:(NSURL *)url; //处理拉起应用
- (void)getQQUserinfo:(TDQQUserinfo)completion;//获取用户信息

@end
