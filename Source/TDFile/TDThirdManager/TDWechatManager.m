//
//  TDWechatManager.m
//  TDThirdLogin
//
//  Created by Elite Edu on 2018/11/9.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDWechatManager.h"
#import <WXApi.h>
#import "OEXConfig.h"
#import "Encryption.h" //md5加密

@interface TDWechatManager () <WXApiDelegate>

@property (nonatomic,copy) TDWechatAuthHandler compleHandler;

@end

@implementation TDWechatManager

+ (instancetype)shareManager {
    static TDWechatManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TDWechatManager alloc] init];
    });
    return manager;
}

+ (void)wechatRegister { //向微信注册
    NSString *appid = [[OEXConfig sharedConfig] weixinAPPID];
    [WXApi registerApp:appid];
}

- (BOOL)wxAppInstall {//是否安装微信
    return [WXApi isWXAppInstalled];
}

- (void)sendWXReq:(TDWechatAuthHandler)compleHandler { //登录
    self.compleHandler = compleHandler;
    
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = @"107" ;
    [WXApi sendReq:req];
}

- (BOOL)handleOpenURL:(NSURL *)url { //处理微信通过URL启动App时传递的数据
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - WXApiDelegate
/**
 是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面。
 */
- (void)onReq:(BaseReq *)req {
    
}

/**
 如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调。sendReq请求调用后，会切到微信终端程序界面。
 */
- (void)onResp:(BaseResp *)resp {
    
    if ([resp isKindOfClass:[PayResp class]]) { //微信支付
        if (resp.errCode == WXSuccess) {
            [self.delegate weixinPaySuccessHandle];
        }
        else {
            NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
            switch (resp.errCode) {
                case WXSuccess:
                    strMsg = @"支付成功";
                    break;
                case WXErrCodeUserCancel:
                    strMsg = @"取消支付";
                    break;
                case WXErrCodeSentFail:
                    strMsg = @"支付失败";
                    break;
                case WXErrCodeAuthDeny:
                    strMsg = @"授权失败";
                    break;
                default:
                    strMsg = @"不支持微信支付";
                    break;
            }
            
            WS(weakSelf);
            NSString *strTitle = @"支付结果";
            UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:strTitle message:strMsg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf.delegate weixinPayFailed:resp.errCode];
            }];
            [alerVC addAction:sureAction];
            
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alerVC animated:YES completion:nil];
        }
    }
    else if ([SendAuthResp class]) { //第三方授权
        SendAuthResp *authResp = (SendAuthResp *)resp;
        [self WXApiUtilsDidRecvAuthResponse:authResp];
    }
}

- (void)WXApiUtilsDidRecvAuthResponse:(SendAuthResp *)response {//第三方登录
    //获取accessToken
    SendAuthResp *oauthResp = (SendAuthResp *)response;
    if (oauthResp.errCode == WXErrCodeAuthDeny) {
        NSLog(@"您已拒绝微信登录");
    }
    else if (oauthResp.errCode == WXErrCodeUserCancel) {
        NSLog(@"您已取消微信登录");
    }
    else if (oauthResp.errCode == WXSuccess) {
        NSLog(@"微信正在登录中 access_token");
    }
    
    if (self.compleHandler != nil) {
        if (response.errCode == WXSuccess) {
            //登录成功
            NSString *appid = [[OEXConfig sharedConfig] weixinAPPID];
            NSString *appSecret = [[OEXConfig sharedConfig] weixinSecret];
            NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",appid,appSecret,response.code];
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *zoneUrl = [NSURL URLWithString:url];
                NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
                NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
                
//                dispatch_async(dispatch_get_main_queue(), ^{
                    if (data) {
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        NSString *access_token = dic[@"access_token"];//获取到的三方凭证
                        NSString *openid = dic[@"openid"];//三方唯一标识
                        
                        self.compleHandler(access_token, openid, nil);
                    }
                    else {
                        NSLog(@"--->> access_token为空");
                        NSError *error = [NSError errorWithDomain:@"普通错误类型" code:WXErrCodeCommon userInfo:nil];
                        self.compleHandler(nil, nil, error);
                    }
//                });
//            });
            NSLog(@"1-微信正在登录中 access_token");
        }
        else {
            NSError *error = [NSError errorWithDomain:@"授权失败" code:response.errCode userInfo:nil];
            self.compleHandler(nil, nil, error);
        }
    }
    [self cleanHandler];
}

- (void)cleanHandler {
    self.compleHandler = nil;
}

//获取微信用户信息
- (void)getWXUserInfoForToken:(NSString *)access_token openid:(NSString *)openid completion:(TDWechatUserinfo)completion {
    
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",access_token,openid];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSMutableDictionary * params = [NSMutableDictionary dictionary];
                [params setValue:openid forKey:@"openid"];//openid【必须】
                [params setValue:[dic objectForKey:@"nickname"] forKey:@"nickName"];//QQ昵称【必须】
                [params setValue:[dic objectForKey:@"headimgurl"] forKey:@"avatar"];//头像【必须】
                [params setValue:[[dic objectForKey:@"sex"] integerValue] == 1 ? @"男":@"女" forKey:@"sex"];//性别【必须】
                NSLog(@"获取用户信息 %@",dic);
                
                completion(params,nil);
                //微信登录
                [self loginSuccess:params];
            }
            else {
                NSLog(@"data为空");
                NSError *error = [NSError errorWithDomain:@"获取微信用户信息错误" code:404 userInfo:nil];
                completion(nil,error);
            }
        });
    });
}

- (void)loginSuccess:(NSDictionary *)response {
    NSLog(@"执行登录 %@",response);
    [self.delegate thirdLoginSuccess:response];
}

#pragma mark - 微信支付
- (void)submitPostWechatPay:(weChatParamsItem *)weChatItem {
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [self getPayParam:weChatItem];
    NSMutableString *stamp = [dict objectForKey:@"timestamp"];
    
    //调起微信支付
    PayReq* req             = [PayReq alloc];
    req.openID              = [dict objectForKey:@"appid"];
    req.partnerId           = [dict objectForKey:@"partnerid"];
    req.prepayId            = weChatItem.prepay_id;
    req.nonceStr            = [dict objectForKey:@"noncestr"];;
    req.timeStamp           = stamp.intValue;
    req.package             = [dict objectForKey:@"package"];
    req.sign                = [dict objectForKey:@"sign"];
    
    [WXApi sendReq:req];
}


- (NSMutableDictionary *)getPayParam:(weChatParamsItem *)weChatItem {
    
    srand( (unsigned)time(0) );
    
    NSString    *package, *time_stamp, *nonce_str;
    //设置支付参数
    time_t now;
    time(&now);
    time_stamp  = [NSString stringWithFormat:@"%ld", now];
    nonce_str    = [Encryption newMd5:time_stamp];
    
    package = @"Sign=WXPay";
    
    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
    [signParams setObject: weChatItem.appid forKey:@"appid"];//开发平台上对应运用的appid
    [signParams setObject: nonce_str forKey:@"noncestr"];//随机串，防重发
    [signParams setObject: package forKey:@"package"]; //商家根据财付通文档填写的数据和签名
    [signParams setObject: weChatItem.mch_id forKey:@"partnerid"];//商户号
    [signParams setObject: time_stamp forKey:@"timestamp"];//时间戳
    [signParams setObject: weChatItem.prepay_id forKey:@"prepayid"];//预处理订单号
    
    NSString *sign  = [self createMd5Sign:signParams];//生成签名
    [signParams setObject:sign forKey:@"sign"];//添加签名
    
    return signParams;//返回参数列表
}

//创建package签名: sign
- (NSString *)createMd5Sign:(NSMutableDictionary *)dict {
    
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
    }
    [contentString appendFormat:@"key=%@", [[OEXConfig sharedConfig] weixinAPPID]];//添加key字段
    
    NSString *md5Sign = [Encryption newMd5:contentString]; //得到MD5 sign签名
    return md5Sign;
}

@end
