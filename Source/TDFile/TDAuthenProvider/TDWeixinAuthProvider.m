//
//  TDWeixinAuthProvider.m
//  edX
//
//  Created by Elite Edu on 2018/11/20.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDWeixinAuthProvider.h"
#import "edX-Swift.h"
#import "OEXExternalAuthProviderButton.h"
#import "OEXRegisteringUserDetails.h"
#import "TDWechatManager.h"

@implementation TDWeixinAuthProvider

- (UIColor*)weixinColor {
    return [UIColor colorWithRed:230./255. green:66./255. blue:55./255. alpha:1];
}

- (NSString*)displayName {
    return @"微信";
}

- (NSString*)backendName {
    return @"weixin";
}

- (UIButton *)freshAuthButton {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setImage:[UIImage imageNamed:@"weixin_logo"] forState:UIControlStateNormal];
//    button.backgroundColor = [self weixinColor];
    return button;
}

- (void)authorizeServiceFromController:(UIViewController *)controller requestingUserDetails:(BOOL)loadUserDetails withCompletion:(void (^)(NSString *, OEXRegisteringUserDetails *, NSError *))completion {
    
    [[TDWechatManager shareManager] sendWXReq:^(NSString *token, NSString *openid, NSError *error) {
        NSLog(@"调用微信 --- %@ ~~ %@  ~~ %@",token,openid,error);
        
        if (error) {
            completion(nil,nil,error);
            return;
        }
        
        if (loadUserDetails) {
            [[TDWechatManager shareManager] getWXUserInfoForToken:token openid:openid completion:^(NSDictionary *userProfile, NSError *error) {
                OEXRegisteringUserDetails *profile = [[OEXRegisteringUserDetails alloc] init];
                profile.name = userProfile[@"nickname"];
                completion(token, profile, error);
            }];
        }
        else {
            completion(token,nil,error);
        }
        
    }];
}

@end
