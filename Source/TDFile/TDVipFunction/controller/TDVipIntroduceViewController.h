//
//  TDVipIntroduceViewController.h
//  edX
//
//  Created by Elite Edu on 2018/12/3.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDVipIntroduceViewController : UIViewController

@property (nonatomic,strong) NSString *urlStr;
@property (nonatomic,copy) void(^gotoCategoryHandle)(void);

@end

NS_ASSUME_NONNULL_END
