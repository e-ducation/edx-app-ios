//
//  TDVipPackageModel.m
//  edX
//
//  Created by Elite Edu on 2018/12/10.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDVipPackageModel.h"

@implementation TDVipPackageModel

- (instancetype)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        [self mappingKeyAndValue:info];
    }
    return self;
}

- (void)mappingKeyAndValue:(NSDictionary *)info {
    self.id = info[@"id"];
    self.is_recommended = info[@"is_recommended"];
    self.month = info[@"month"];
    self.name = info[@"name"];
    self.price = info[@"price"];
    self.suggested_price = info[@"suggested_price"];
}

@end
