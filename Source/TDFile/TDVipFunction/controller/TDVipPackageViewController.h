//
//  TDVipPackageViewController.h
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDVipPackageViewController : UIViewController

@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *vipID;
@property (nonatomic,strong) void(^vipBuySuccessHandle)(void);

@end

NS_ASSUME_NONNULL_END
