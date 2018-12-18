//
//  TDAliPayModel.m
//  edX
//
//  Created by Elite Edu on 17/1/14.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDAliPayModel.h"

@implementation TDAliPayModel

- (instancetype)initWithOrder:(NSDictionary *)order {
    self = [super init];
    if (self) {
        [self mappingKeyAndValue:order];
    }
    return self;
}

- (void)mappingKeyAndValue:(NSDictionary *)order {
    
    self.total_fee = order[@"total_fee"];//总金额
    self.out_trade_no = order[@"out_trade_no"];//商户网站唯一订单号
    self.subject = order[@"subject"];//商品名称
    self.body = order[@"body"]; //商品详情
    self.seller_email = order[@"seller_email"];//卖家支付宝账号
    self.seller_id = order[@"seller_id"];//卖家支付宝ID
    self.service = order[@"service"];//接口名称
    self._input_charset = order[@"_input_charset"];//参数编码字符集
    self.sign = order[@"sign"]; //签名
    self.payment_type = order[@"payment_type"];//支付类型
    self.notify_url = order[@"notify_url"];//服务器异步通知页面路径
    self.sign_type = order[@"sign_type"];//签名方式
    self.partner = order[@"partner"];//合作者身份ID
    self.it_b_pay = order[@"it_b_pay"];//超时设置

}

@end
