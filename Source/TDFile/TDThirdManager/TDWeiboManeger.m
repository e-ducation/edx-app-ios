//
//  TDWeiboManeger.m
//  TDThirdLogin
//
//  Created by Elite Edu on 2018/11/12.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDWeiboManeger.h"
#import <Weibo_SDK/WeiboSDK.h>
#import <AFNetworking/AFNetworking.h>
#import "OEXConfig.h"

@interface TDWeiboManeger () <WeiboSDKDelegate>
@property (nonatomic,strong) WBAuthorizeRequest *request;
@property (nonatomic,copy) TDSinaWbAuthCompleHandler compleHandler;
@end

@implementation TDWeiboManeger

+ (instancetype)shareManager {
    static TDWeiboManeger *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TDWeiboManeger alloc] init];
    });
    return manager;
}

//微博注册
+ (void)weiboRegister:(BOOL)enable {
    NSString *key = [[OEXConfig sharedConfig] sinaAPPKey];
    [WeiboSDK enableDebugMode:enable];
    [WeiboSDK registerApp:key];
}

//微博登录
- (void)weiboAuthLogin:(TDSinaWbAuthCompleHandler)compleHandler {
    self.compleHandler = compleHandler;
    
    NSString *redirectUrl = [[OEXConfig sharedConfig] sinaTRedirectUrl];
    self.request = [WBAuthorizeRequest request];
    self.request.redirectURI = redirectUrl;
    self.request.scope = @"all";
    self.request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:self.request];
}

//是否已安装
- (BOOL)isWeiboInstalled {
    return [WeiboSDK isWeiboAppInstalled];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [WeiboSDK handleOpenURL:url delegate:self];
}

#pragma mark - WeiboSDKDelegate
/**
 收到一个来自微博客户端程序的请求
 
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    if ([request isKindOfClass:WBAuthorizeRequest.class]) {
        
    }
}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {//成功
            NSLog(@"微博 -- 成功");
        }
        else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel) {//用户取消发送
            NSLog(@"微博 -- 用户取消发送");
        }
        else if (response.statusCode == WeiboSDKResponseStatusCodeSentFail) {//发送失败
            NSLog(@"微博 -- 发送失败");
        }
        else if (response.statusCode == WeiboSDKResponseStatusCodeAuthDeny) {//授权失败
            NSLog(@"微博 -- 授权失败");
        }
        
        if (self.compleHandler != nil) {
            if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
                WBAuthorizeResponse *authResp = (WBAuthorizeResponse *)response;
                self.compleHandler(authResp.accessToken, authResp.userID, nil);
            }
            else {
                NSError *error = [NSError errorWithDomain:@"错误" code:response.statusCode userInfo:nil];
                self.compleHandler(nil, nil, error);
            }
        }
        [self cleanHandler];
    }
}

- (void)cleanHandler {
    self.compleHandler = nil;
}


- (void)getWeiboUserInfo:(NSString *)accessToken userid:(NSString *)userID completion:(TDSinaUserInfo)completion {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:accessToken forKey:@"access_token"];
    [dic setValue:userID forKey:@"uid"];
    
    NSString *url = @"https://api.weibo.com/2/users/show.json";
    NSLog(@"微博 -->> %@",dic);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"微博成功获取信息 -- %@",responseObject);
        NSDictionary *dic = (NSDictionary *)responseObject;
        completion(dic,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"微博获取信息失败 -- %@",error);
        completion(nil,error);
    }];
}


@end
