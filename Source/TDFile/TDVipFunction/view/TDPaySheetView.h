//
//  TDPaySheetView.h
//  edX
//
//  Created by Elite Edu on 2018/12/3.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDPayView.h"
#import "edX-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDPaySheetView : UIView

@property (nonatomic,strong) SpinnerButton *payButton;
@property (nonatomic,strong) TDPayView *wechatView;
@property (nonatomic,strong) TDPayView *aliPayView;

- (void)showSheetAnimation:(CGFloat)price; //显示支付页面
- (void)sheetDisapear; //隐藏
- (void)selectPayStyle:(NSInteger)type; //选择支付方式

@end

NS_ASSUME_NONNULL_END
