//
//  UIColor+TDHexColor.h
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (TDHexColor)

+ (UIColor *)colorWithHexString:(NSString *)colorStr;

@end

NS_ASSUME_NONNULL_END
