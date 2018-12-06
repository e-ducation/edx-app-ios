//
//  WeChatPay.h
//  edX
//
//  Created by Elite Edu on 16/11/25.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "weChatParamsItem.h"

@interface WeChatPay : NSObject

- (void)submitPostWechatPay:(weChatParamsItem *)weChatItem; 

@end
