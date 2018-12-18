//
//  PurchaseModel.m
//  edX
//
//  Created by Elite Edu on 16/11/22.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "PurchaseModel.h"

@implementation PurchaseModel

- (NSMutableDictionary *)autoParameteDictionary {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:[NSString stringWithFormat:@"%@",self.trader_num] forKey:@"order_id"];
    [dic setValue:[NSString stringWithFormat:@"%@",self.total_fee] forKey:@"total_fee"];
    [dic setValue:[NSString stringWithFormat:@"%@",self.apple_receipt] forKey:@"receipt"];
    [dic setValue:[NSString stringWithFormat:@"%@",self.package_id] forKey:@"package_id"];
    
    return dic;
}

@end
