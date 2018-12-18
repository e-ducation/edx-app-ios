//
//  TDVipPackageHeaderView.h
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDVipMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDVipPackageHeaderView : UIView

/**
 VIP信息数据
 @param type 0 未购买，1 已购买，2 已过期
 */
- (void)packageViewMessage:(TDVipMessageModel *)messageModel;

@end

NS_ASSUME_NONNULL_END
