//
//  TDWechatManager.h
//  TDThirdLogin
//
//  Created by Elite Edu on 2018/11/9.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDWXDelegate <NSObject>

@optional
- (void)thirdLoginSuccess:(NSDictionary *)response; //登录成功

@end

typedef void (^TDWechatAuthHandler)(NSString *token,NSString *openid,NSError *error);
typedef void (^TDWechatUserinfo)(NSDictionary *userProfile,NSError *error);

@interface TDWechatManager : NSObject

@property (nonatomic,weak) id <TDWXDelegate> delegate;

+ (instancetype)shareManager; //初始化
+ (void)wechatRegister; //向微信注册
- (BOOL)wxAppInstall; //是否安装微信
- (void)sendWXReq:(TDWechatAuthHandler)compleHandler;  //登录
- (BOOL)handleOpenURL:(NSURL *)url; //处理微信通过URL启动App时传递的数据
-(void)getWXUserInfoForToken:(NSString *)access_token openid:(NSString *)openid completion:(TDWechatUserinfo)completion;//获取用户信息

@end
