//
//  TDVipPackageModel.h
//  edX
//
//  Created by Elite Edu on 2018/12/10.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDVipPackageModel : NSObject

- (instancetype)initWithInfo:(NSDictionary *)info;

@property (nonatomic,strong) NSNumber *id;
@property (nonatomic,strong) NSNumber *is_recommended;
@property (nonatomic,strong) NSString *month;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *price;
@property (nonatomic,strong) NSString *suggested_price;

@end

NS_ASSUME_NONNULL_END
