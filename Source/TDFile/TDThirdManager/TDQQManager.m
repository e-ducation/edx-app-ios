//
//  TDQQManager.m
//  TDThirdLogin
//
//  Created by Elite Edu on 2018/11/9.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDQQManager.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <AFNetworking/AFNetworking.h>
#import "OEXConfig.h"

@interface TDQQManager () <TencentLoginDelegate,TencentSessionDelegate>

@property (nonatomic,copy) TDQQAuthHandler compleHandler;
@property (nonatomic,copy) TDQQUserinfo completion;
@property (nonatomic,strong) TencentOAuth *tencentOauth;
@end

@implementation TDQQManager

+ (instancetype)shareManager {
    static TDQQManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TDQQManager alloc] init];
    });
    return manager;
}


/**
 登录
 */
- (void)qqAuthenLogin:(TDQQAuthHandler)compleHandler {
    self.compleHandler = compleHandler;
    
    NSString *appid = [[OEXConfig sharedConfig] tencentAPPID];
    self.tencentOauth = [[TencentOAuth alloc] initWithAppId:appid andDelegate:self];
//    self.tencentOauth.authShareType = AuthShareType_QQ;
    NSArray *array = [NSArray arrayWithObjects:
                      kOPEN_PERMISSION_GET_USER_INFO,
                      kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                      kOPEN_PERMISSION_ADD_SHARE,
                      kOPEN_PERMISSION_GET_INFO, nil];
    [self.tencentOauth authorize:array];
}


/**
 是否已安装QQ
 */
- (BOOL)isQQInstalled {
    return [TencentOAuth iphoneQQInstalled];
}

/**
 * (静态方法)处理应用拉起协议
 * \param url 处理被其他应用呼起时的逻辑
 * \return 处理结果，YES表示成功，NO表示失败
 */
- (BOOL)handleOpenURL:(NSURL *)url {
    NSLog(@"qq---222");
    return [TencentOAuth HandleOpenURL:url];
}

#pragma mark - TencentLoginDelegate
/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin {
    NSLog(@"qq---登录成功");
    self.compleHandler(self.tencentOauth.accessToken, self.tencentOauth.openId, nil);
    [self cleanCompleHandler];
//    [self.tencentOauth getUserInfo];
    
}
/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        NSLog(@"qq取消登录");
    }
    else {
        NSLog(@"qq登录失败");
    }
    NSError *error = [NSError errorWithDomain:@"登录失败" code:404 userInfo:nil];
    self.compleHandler(nil, nil, error);
    [self cleanCompleHandler];
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork {
    NSLog(@"qq登录无网络");
    [self cleanCompleHandler];
}

#pragma mark - TencentSessionDelegate
/**
 * 退出登录的回调
 */
- (void)tencentDidLogout {
    NSLog(@"qq退出登录");
    [self cleanCompleHandler];
}

/**
 * 因用户未授予相应权限而需要执行增量授权。在用户调用某个api接口时，如果服务器返回操作未被授权，则触发该回调协议接口，由第三方决定是否跳转到增量授权页面，让用户重新授权。
 * \param tencentOAuth 登录授权对象。
 * \param permissions 需增量授权的权限列表。
 * \return 是否仍然回调返回原始的api请求结果。
 * \note 不实现该协议接口则默认为不开启增量授权流程。若需要增量授权请调用\ref TencentOAuth#incrAuthWithPermissions: \n注意：增量授权时用户可能会修改登录的帐号
 */
- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions {
    [tencentOAuth incrAuthWithPermissions:permissions];
    NSLog(@"qq---1");
    return NO;
}

/**
 * [该逻辑未实现]因token失效而需要执行重新登录授权。在用户调用某个api接口时，如果服务器返回token失效，则触发该回调协议接口，由第三方决定是否跳转到登录授权页面，让用户重新授权。
 * \param tencentOAuth 登录授权对象。
 * \return 是否仍然回调返回原始的api请求结果。
 * \note 不实现该协议接口则默认为不开启重新登录授权流程。若需要重新登录授权请调用\ref TencentOAuth#reauthorizeWithPermissions: \n注意：重新登录授权时用户可能会修改登录的帐号
 */
- (BOOL)tencentNeedPerformReAuth:(TencentOAuth *)tencentOAuth {
    NSLog(@"qq---2");
    return YES;
}

/**
 * 获取用户个人信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * response.retCode 网络请求是否成功送达服务器，以及服务器返回的数据格式是否正确 
 * response.detailRetCode 主要用于区分不同的错误情况
 */
- (void)getUserInfoResponse:(APIResponse *)response {
    
    if (URLREQUEST_SUCCEED == response.retCode && kOpenSDKErrorSuccess == response.detailRetCode) {
        [self qqLoginGetUserInfoResponse:response];
    }
    else {
        NSError *error = [NSError errorWithDomain:@"获取QQ用户信息错误" code:404 userInfo:nil];
        self.completion(nil, error);
        [self cleanCompletion];
    }
    NSLog(@"qq---3");
}


#pragma mark - 获取用户个人信息
- (void)getQQUserinfo:(TDQQUserinfo)completion {
    self.completion = completion;
    [self.tencentOauth getUserInfo];
}

- (void)qqLoginGetUserInfoResponse:(APIResponse *)response {
    NSLog(@"获取用户信息%@",response.jsonResponse);
    
    NSInteger gender = 0;
    if ([response.jsonResponse[@"gender"] isEqualToString:@"男"]) {
        gender = 1;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.tencentOauth.openId forKey:@"openid"];
    [params setValue:self.tencentOauth.accessToken forKey:@"accessToken"];
    [params setValue:[response.jsonResponse objectForKey:@"nickname"] forKey:@"nickName"];//QQ昵称【必须】
    [params setValue:[response.jsonResponse objectForKey:@"figureurl_qq_2"] forKey:@"avatar"];//头像【必须】
    [params setValue:gender == 1 ? @"男":@"女" forKey:@"sex"];//性别【必须】
    
    self.completion(params, nil);
    [self loginSuccess:params];
}

- (void)loginSuccess:(NSDictionary *)dic {
    NSLog(@"登录成功 -->> %@",dic);
    
}

- (void)cleanCompleHandler {
    self.compleHandler = nil;
}

- (void)cleanCompletion {
    self.completion = nil;
}


@end
