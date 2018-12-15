//
//  TDAlipayManager.h
//  edX
//
//  Created by Elite Edu on 2018/12/7.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDAliPayModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TDAlipayDelegate <NSObject>

- (void)alipaySuccessHandle;
- (void)alipayFaile:(NSInteger)status;

@end

@interface TDAlipayManager : NSObject

@property (nonatomic,weak) id <TDAlipayDelegate>delegate;

+ (instancetype)shareManager;

- (void)sumbmitAliPay:(NSString *)orderString; //接口直接拼接
- (void)sumbmitAliPayOrder:(TDAliPayModel *)aliPayModel;//调起支付
- (void)processOrderWithPaymentResult:(NSURL *)url; //处理调起

@end

NS_ASSUME_NONNULL_END
