//
//  TDAlipayManager.m
//  edX
//
//  Created by Elite Edu on 2018/12/7.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDAlipayManager.h"
#import <AlipaySDK/AlipaySDK.h>
#import "APOrderInfo.h"
#import "APRSASigner.h"
#import "OEXConfig.h"

@implementation TDAlipayManager

+ (instancetype)shareManager {
    
    static TDAlipayManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TDAlipayManager alloc] init];
    });
    return manager;
}

- (void)sumbmitAliPay:(TDAliPayModel *)aliPayModel {

    NSString *appID = [[OEXConfig sharedConfig] alipayAPPID];
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    APOrderInfo* order = [APOrderInfo new];
    
    // NOTE: app_id设置
    order.app_id = appID;
    
    // NOTE: 支付接口名称
    order.method = aliPayModel.service;//@"alipay.trade.app.pay"; //回调地址
    
    // NOTE: 参数编码格式
    order.charset = @"utf-8"; //参数编码格式
    
    // NOTE: 当前时间点
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]]; //请求发送的时间
    
    // NOTE: 支付版本
    order.version = @"1.0";
    
    // NOTE: sign_type 根据商户设置的私钥来决定
    order.sign_type = @"RSA"; //(rsa2PrivateKey.length > 1)?@"RSA2":@"RSA";
    
    // NOTE: 商品数据
    order.biz_content = [APBizContent new];
    order.biz_content.body = aliPayModel.body; //商品详情
    order.biz_content.subject = aliPayModel.subject; //商品标题
    order.biz_content.out_trade_no = aliPayModel.out_trade_no; //订单ID（由商家自行制定
    order.biz_content.timeout_express = @"30m"; //超时时间设置
    order.biz_content.total_amount = aliPayModel.total_fee;//[NSString stringWithFormat:@"%.2f", 0.01]; //商品价格
//    order.biz_content.seller_id = aliPayModel.seller_id; //收款支付宝用户ID。 如果该值为空，则默认为商户签约账号对应的支付宝用户ID
    
    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    NSLog(@"orderSpec = %@",orderInfo);
    
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    NSString *base64String = aliPayModel.sign;
    NSString *signedString = [self urlEncodedString:base64String];
    
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"alipayEliteMba";
        
        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                 orderInfoEncoded, signedString];
        
        // NOTE: 调用支付结果开始支付
        WS(weakSelf);
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"手机未安装支付宝 reslut = %@",resultDic);
            
            [weakSelf dealWithAlipayResult:resultDic];
        }];
    }
}

- (void)processOrderWithPaymentResult:(NSURL *)url {
    
    // 支付跳转支付宝钱包进行支付，处理支付结果
    WS(weakSelf);
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"支付宝支付 result = %@",resultDic);
        
        [weakSelf dealWithAlipayResult:resultDic];
    }];
    
}

- (void)dealWithAlipayResult:(NSDictionary *)resultDic {
    NSString *resultStatus = resultDic[@"resultStatus"];
    NSString *strTitle = @"支付结果";
    NSString *str;
    switch ([resultStatus integerValue]) {
        case 6001:
            str = @"取消支付";
            break;
        case 9000:
            str = @"支付成功";
            break;
        case 8000:
            str = @"正在处理...";
            break;
        case 4000:
            str = @"支付失败";
            break;
        case 6002:
            str = @"网络出错";
            break;
            
        default:
            break;
    }
    if ([resultStatus isEqualToString:@"9000"]) {
        [self.delegate alipaySuccessHandle];
    }
    else {
        WS(weakSelf);
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:strTitle message:str preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.delegate alipayFaile:[resultStatus integerValue]];
        }];
        [alertVc addAction:sureAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVc animated:YES completion:nil];
    }
}

#pragma mark - 编码
- (NSString*)urlEncodedString:(NSString *)string {

    NSString *charactersToEscape = @"#[]@!$'()*+,;\"<>%{}|^~`";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodedUrl = [[string description] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return encodedUrl;
}


@end
