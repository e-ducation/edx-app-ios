//
//  TDVipPackageView.h
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TDVipPayDelegate <NSObject>

/**
 支付

 @param type 支付方式：0 微信，1 支付宝
 @param price 支付价格
 */
- (void)gotoPayByType:(NSInteger)type price:(NSString *)price;

@end

@interface TDVipPackageView : UIView

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,weak,nullable) id <TDVipPayDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
