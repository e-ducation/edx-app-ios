//
//  TDSinaWBAuthProvider.m
//  edX
//
//  Created by Elite Edu on 2018/11/19.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSinaWBAuthProvider.h"
#import "edX-Swift.h"
#import "OEXExternalAuthProviderButton.h"
#import "TDWeiboManeger.h"
#import "OEXRegisteringUserDetails.h"

@implementation TDSinaWBAuthProvider

- (UIColor*)sinaWbColor {
    return [UIColor orangeColor];
}

- (NSString*)displayName {
    return @"微博";
}

- (NSString*)backendName {
    return @"weibo";
}

- (UIButton *)freshAuthButton {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setImage:[UIImage imageNamed:@"weibo_logo"] forState:UIControlStateNormal];
//    button.backgroundColor = [self sinaWbColor];
    return button;
}

- (void)authorizeServiceFromController:(UIViewController *)controller requestingUserDetails:(BOOL)loadUserDetails withCompletion:(void (^)(NSString *, OEXRegisteringUserDetails *, NSError *))completion {
    
    [[TDWeiboManeger shareManager] weiboAuthLogin:^(NSString *token, NSString *userid, NSError *error) {
        NSLog(@"调用微博 --- %@ ~~ %@  ~~ %@",token,userid,error);
        if (error) {
            completion(nil,nil,error);
            return;
        }
        
        completion(token,nil,error);
        if (loadUserDetails) {
            [[TDWeiboManeger shareManager] getWeiboUserInfo:token userid:userid completion:^(NSDictionary *userProfile, NSError *error) {
                OEXRegisteringUserDetails *profile = [[OEXRegisteringUserDetails alloc] init];
                profile.email = userProfile[@"email"];
                profile.name = userProfile[@"name"];
                completion(token, profile, error);
            }];
        }
        else {
            completion(token,nil,error);
        }
    }];
}

@end
