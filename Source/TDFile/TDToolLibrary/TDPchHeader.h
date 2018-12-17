//
//  TDPchHeader.h
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#ifndef TDPchHeader_h
#define TDPchHeader_h

#import <Masonry/Masonry.h>
#import "UIColor+TDHexColor.h"
#import "UIView+Toast.h"
#import "OEXConfig.h"
#import "OEXNetworkConstants.h"
#import <SVProgressHUD/SVProgressHUD.h>

#define ELITEU_URL [OEXConfig sharedConfig].apiHostURL

#define TDWidth [UIScreen mainScreen].bounds.size.width
#define TDHeight [UIScreen mainScreen].bounds.size.height

#if __has_feature(objc_arc)
#define WS(weakSelf) __weak typeof(&*self)weakSelf = self
#else
#define WS(weakSelf) __block typeof(&*self)weakSelf = self
#endif


#endif /* TDPchHeader_h */
