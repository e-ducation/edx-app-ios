//
//  TDVipMessageModel.m
//  edX
//
//  Created by Elite Edu on 2018/12/10.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDVipMessageModel.h"
#import "NSObject+OEXReplaceNull.h"
#import "edX-Swift.h"

@interface TDVipMessageModel ()

@property (nonatomic,strong) NSDate *date;

@end

@implementation TDVipMessageModel

- (instancetype)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        [self mappingKeyAndValue:info];
    }
    return self;
}

- (void)mappingKeyAndValue:(NSDictionary *)info {
    
    info = [info oex_replaceNullsWithEmptyStrings];
    
    self.is_vip = info[@"is_vip"];
    self.vip_expired_days = info[@"vip_expired_days"];
    self.vip_pass_days = info[@"vip_pass_days"];
    self.vip_remain_days = info[@"vip_remain_days"];;
    
    NSDate *startDate = [DateFormatting dateWithServerString:info[@"start_at"]];
    NSDate *endDate = [DateFormatting dateWithServerString:info[@"expired_at"]];
    NSDate *lastDate = [DateFormatting dateWithServerString:info[@"last_start_at"]];
    
    self.start_at = [self getStringFromDate:startDate];
    self.expired_at = [self getStringFromDate:endDate];
    self.last_start_at = [self getStringFromDate:lastDate];
}

- (NSString *)getStringFromDate:(NSDate *)date {
    NSDateFormatter *formmat = [[NSDateFormatter alloc] init];
    [formmat setDateFormat:@"yyyy-MM-dd"];
    return [formmat stringFromDate:date];
}


@end
