//
//  TDVipMessageModel.h
//  edX
//
//  Created by Elite Edu on 2018/12/10.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDVipMessageModel : NSObject

- (instancetype)initWithInfo:(NSDictionary *)info;

@property (nonatomic,strong) NSString *expired_at;
@property (nonatomic,strong) NSString *is_vip;
@property (nonatomic,strong) NSString *start_at;
@property (nonatomic,strong) NSNumber *vip_expired_days;
@property (nonatomic,strong) NSNumber *vip_pass_days;
@property (nonatomic,strong) NSNumber *vip_remain_days;

@end

NS_ASSUME_NONNULL_END
