//
//  TDPurchaseSqliteOperation.h
//  edX
//
//  Created by Elite Edu on 2018/6/20.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PurchaseModel.h"
#import "FMDatabase.h"

typedef void(^SqliteQuerySortHandler)(NSMutableArray *downloadArray, NSMutableArray *finishArray);

@interface TDPurchaseSqliteOperation : NSObject

@property (nonatomic,strong) FMDatabase *dataBase;
@property (nonatomic,strong) NSString *sqlitePath;

- (void)createSqliteForUser:(NSString *)username; //创建数据库和表
- (void)insertFileData:(PurchaseModel *)model payStatus:(BOOL)isPayed; //增
- (void)deleteOrderDataForOrderId:(NSString *)order_id; //根据订单id来删除
- (void)deleteAllOrderData;//删除全部
- (void)updateOrderStatus:(BOOL)isPayed orderId:(NSString *)order_idj;//更新状态

- (NSMutableArray *)querySqliteAllData;//查所有的数据



@end
