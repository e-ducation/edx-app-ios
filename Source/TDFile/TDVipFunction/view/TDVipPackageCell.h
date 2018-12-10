//
//  TDVipPackageCell.h
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDVipPackageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDVipPackageCell : UITableViewCell

@property (nonatomic,assign) BOOL isSelect;
@property (nonatomic,strong) UIButton *bgButton;

@property (nonatomic,strong) TDVipPackageModel *model;

@end

NS_ASSUME_NONNULL_END
