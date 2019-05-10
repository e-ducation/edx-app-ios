//
//  PurchaseModel.h
//  edX
//
//  Created by Elite Edu on 16/11/22.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PurchaseModel : NSObject

@property (nonatomic,strong) NSString *order_id;//订单号
@property (nonatomic,strong) NSString *total_fee;//订单金额
@property (nonatomic,strong) NSString *package_id;//VIP套餐id
@property (nonatomic,strong) NSString *apple_receipt;//app store返回的凭证数据
@property (nonatomic,strong) NSString *transaction_id;//内购交易id

- (NSMutableDictionary *)autoParameteDictionary;

@end
