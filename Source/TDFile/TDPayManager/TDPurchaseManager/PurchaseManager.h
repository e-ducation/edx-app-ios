//
//  PurchaseManager.h
//  edX
//
//  Created by Elite Edu on 16/11/22.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "PurchaseModel.h"

@protocol TDPurchaseDelegate <NSObject>

/** 内购票据验证 */
- (void)updatedTransactionReceiveStr:(NSString *)receiveStr;

/** 未卸载App情况下的，掉单重新验证 */
- (void)updatedLostOrderVertified:(PurchaseModel *)model;
/** 卸载App再重装后，掉单重新验证 */
- (void)newOrderPrice:(int)price transactionReceiveStr:(NSString *)receiveStr;

/** 支付失败 */
- (void)transactionPaymentFailed;

@end

typedef NS_ENUM(NSInteger,IAP) {
    IAP_198 = 1,
    IAP_488,
    IAP_898,
    IAP_1198,
};

@interface PurchaseManager : NSObject <SKPaymentTransactionObserver,SKProductsRequestDelegate> {
    int buyType;
}

@property (nonatomic,weak,nullable) id <TDPurchaseDelegate>delegate;
@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) PurchaseModel *model;
@property (nonatomic,strong) UIViewController *viewController;

- (void)showPurchaseComplete:(void(^)(BOOL approveSucess))completion;//App是否审核通过
- (void)verificationAction:(PurchaseModel *)purchaseModel completion:(void(^)(BOOL isSuccess))completion;//App Store验证
- (void)reqToUpMoneyFromApple:(int)type; //发起内购

- (void)deleteAllIAPOrderData;//删除订单信息

@end

