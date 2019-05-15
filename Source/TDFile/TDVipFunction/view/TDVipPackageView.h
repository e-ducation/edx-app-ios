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


@end

NS_ASSUME_NONNULL_END
