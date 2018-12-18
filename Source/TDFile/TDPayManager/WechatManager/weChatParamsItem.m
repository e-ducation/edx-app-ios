//
//  weChatParamsItem.m
//  edX
//
//  Created by Elite Edu on 16/9/12.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "weChatParamsItem.h"

@implementation weChatParamsItem

- (instancetype)initWithOroderDic:(NSDictionary *)order {
    self = [super init];
    if (self) {
        [self mappingKeyAndValue:order];
    }
    return self;
}
/*
 //购买课程订单号
 @property (nonatomic,strong) NSString *order_id;
 */
- (void)mappingKeyAndValue:(NSDictionary *)order {
    self.appid = order[@"appid"];
    self.mch_id = order[@"mch_id"];
    self.nonce_str = order[@"nonce_str"];
    self.package = order[@"package"];
    self.prepay_id = order[@"prepay_id"];
    self.sign = order[@"sign"];
    self.timestamp = order[@"timestamp"];
    
}

@end
