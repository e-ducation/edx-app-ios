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

/**
 更新内购交易结果
 */
- (void)updatedTAppApproveransactions:(int)state receiveStr:(NSString *)receiveStr;

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

- (void)showPurchaseComplete:(void(^)(BOOL approveSucess))completion;//App是否审核通过
- (void)verificationAction:(PurchaseModel *)purchaseModel completion:(void(^)(id dataObject, BOOL isSuccess))completion;//App Store验证
- (void)reqToUpMoneyFromApple:(int)type; //发起内购

@end

