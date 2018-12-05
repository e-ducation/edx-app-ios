//
//  TDPayView.h
//  edX
//
//  Created by Elite Edu on 2018/12/3.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDPayView : UIView

- (instancetype)initWithType:(NSInteger)type;
@property (nonatomic,strong) UIButton *selectButton;
@property (nonatomic,strong) UIButton *checkButton;

@end

NS_ASSUME_NONNULL_END
