//
//  TDVipPackageHeaderView.h
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDVipPackageHeaderView : UIView

/**
 VIP信息数据
 @param start 开始时间
 @param end 到期时间
 @param validStr 剩余多少天/已过期多少天
 @param pastStr  已过多少天
 @param type 0 未购买，1 已购买，2 已过期
 */
- (void)packageStart:(nullable NSString *)start end:(nullable NSString *)end validStr:(nullable NSString *)validStr pastStr:(nullable NSString *)pastStr type:(NSInteger)type;

@end

NS_ASSUME_NONNULL_END
