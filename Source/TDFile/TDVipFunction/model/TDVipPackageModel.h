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

@property (nonatomic,strong) NSNumber *id;//id
@property (nonatomic,strong) NSNumber *is_recommended; //是否是推荐
@property (nonatomic,strong) NSString *month; //月数
@property (nonatomic,strong) NSString *name; //名字
@property (nonatomic,strong) NSString *price; //价格
@property (nonatomic,strong) NSString *suggested_price; //建议价格

@end

NS_ASSUME_NONNULL_END
