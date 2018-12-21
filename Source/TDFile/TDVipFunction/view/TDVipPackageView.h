//
//  TDVipPackageView.h
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDVipMessageModel.h"
#import "TDVipPackageModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TDVipPayDelegate <NSObject>
/**
 支付

 @param type 支付方式：0 微信，1 支付宝
 @param vipID vip对应id
 */
- (void)gotoPayByType:(NSInteger)type vipID:(NSString *)vipID;
/**
 调起内购
 */
- (void)appApproveProgress:(TDVipPackageModel *)model;

@end

@interface TDVipPackageView : UIView

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,weak,nullable) id <TDVipPayDelegate> delegate;

@property (nonatomic,strong,nullable) NSString *vipID;
@property (nonatomic,strong) TDVipMessageModel *messageModel;
@property (nonatomic,strong) NSArray <TDVipPackageModel *> *vipArray;

@property (nonatomic,assign) BOOL approveSucess;//App审核通过
@property (nonatomic,strong) UINavigationController *navigationController;

- (void)vipPaySheetViewDisapear;//收回支付页面

@end

NS_ASSUME_NONNULL_END
