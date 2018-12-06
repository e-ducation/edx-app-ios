//
//  weChatParamsItem.h
//  edX
//
//  Created by Elite Edu on 16/9/12.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface weChatParamsItem : NSObject
//APPID
@property (nonatomic,strong) NSString *appid;
//商户号
@property (nonatomic,strong) NSString *mch_id;
//支付签名随机字符串
@property (nonatomic,strong) NSString *nonce_str;
//购买课程订单号
@property (nonatomic,strong) NSString *order_id;
//订单详情扩展字符串
@property (nonatomic,strong) NSString *package;
//预处理订单ID
@property (nonatomic,strong) NSString *prepay_id;
//签名
@property (nonatomic,strong) NSString *sign;

@end
