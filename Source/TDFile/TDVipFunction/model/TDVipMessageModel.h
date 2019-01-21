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

@property (nonatomic,strong) NSString *expired_at; //过期日期
@property (nonatomic,strong) NSString *is_vip; //VIP？
@property (nonatomic,strong) NSString *start_at;  //开通时间
@property (nonatomic,strong) NSNumber *vip_expired_days; //过期天数
@property (nonatomic,strong) NSNumber *vip_pass_days; //过去天数
@property (nonatomic,strong) NSNumber *vip_remain_days; //剩余天数
@property (nonatomic,strong) NSString *last_start_at;//上次开通时间

@end

NS_ASSUME_NONNULL_END
