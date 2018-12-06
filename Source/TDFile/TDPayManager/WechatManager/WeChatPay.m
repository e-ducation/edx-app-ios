//
//  WeChatPay.m
//  edX
//
//  Created by Elite Edu on 16/11/25.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "WeChatPay.h"
#import "WXApi.h"
#import "Encryption.h" //md5加密
#import "OEXConfig.h"

@implementation WeChatPay

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
    nonce_str	= [Encryption newMd5:time_stamp];
    
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
