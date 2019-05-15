//
//  TDPurchaseSqliteOperation.m
//  edX
//
//  Created by Elite Edu on 2018/6/20.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDPurchaseSqliteOperation.h"

@implementation TDPurchaseSqliteOperation

#pragma mark - 创建数据库
- (void)createSqliteForUser:(NSString *)username { //初始化FMDatabase
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.sqlitePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_purchase_File.sqlite",username]];
    self.dataBase = [FMDatabase databaseWithPath:self.sqlitePath]; //初始化对象
    
    [self createSqliteTable];
}

- (void)createSqliteTable { //创建表
    
    if ([self.dataBase open]) {
        
        NSString *createSql = @"CREATE TABLE IF NOT EXISTS purchase_table (id text NOT NULL, package_id text NOT NULL, total_fee text, transaction_id text, status integer);";
        BOOL result = [self.dataBase executeUpdate:createSql];
        if (result) {
            NSLog(@"创建表成功");
        }
        else {
            NSLog(@"创建表失败");
        }
    }
    else {
        NSLog(@"打开数据库失败");
    }
    [self.dataBase close];
}

#pragma mark - 增
- (void)insertFileData:(PurchaseModel *)model payStatus:(BOOL)isPayed {
    
    if ([self.dataBase open]) {
    
        NSString *insetSql = @"INSERT INTO purchase_table (id, package_id, total_fee, transaction_id, status) VALUES (?,?,?,?,?)";
        BOOL insert = [self.dataBase executeUpdate:insetSql, model.order_id, model.package_id, model.total_fee, model.transaction_id, @(isPayed)];
        
        if (insert) {
            NSLog(@"插入成功 %@",model.order_id);
        }
        else {
            NSLog(@"插入失败 %@",model.order_id);
        }
    }
    else {
        NSLog(@"增 - 打开数据库失败");
    }
    [self.dataBase close];
}

#pragma mark - 删
- (void)deleteOrderDataForOrderId:(NSString *)order_id { //根据文件id来删除删
    
    if ([self.dataBase open]) {
    
        BOOL delete = [self.dataBase executeUpdate:@"delete from purchase_table where id = ?", order_id];
        if (delete) {
            NSLog(@"数据库 --> 删除成功 %@", order_id);
        }
        else {
            NSLog(@"数据库 --> 删除失败 %@", order_id);
        }
    }
    [self.dataBase close];
}

- (void)deleteAllOrderData {
    if ([self.dataBase open]) {
        
        BOOL delete = [self.dataBase executeUpdate:@"delete from purchase_table"];
        if (delete) {
            NSLog(@"数据库 --> 删除全部");
        }
        else {
            NSLog(@"数据库 --> 删除全部失败");
        }
    }
    [self.dataBase close];
}

#pragma mark - 改
- (void)updateOrderStatus:(BOOL)isPayed orderId:(NSString *)order_id {//更新状态
    
    if ([self.dataBase open]) {
        BOOL change = [self.dataBase executeUpdate:@"update purchase_table set status = ? where id = ?", @(isPayed), order_id];
        if (change) {
            NSLog(@"status更新成功 %@ -> %d",order_id,isPayed);
        }
        else {
            NSLog(@"status更新失败  %@",order_id);
        }
    }
    
    [self.dataBase close];
}

#pragma mark - 查
- (NSMutableArray *)querySqliteAllData { //查整个表
    
    NSMutableArray *downloadArray = [[NSMutableArray alloc] init];
    if ([self.dataBase open]) {
        
        NSString *queryStr = @"select * from purchase_table";
        FMResultSet *result = [self.dataBase executeQuery:queryStr];
        if (result) {
            
            while ([result next]) {
                PurchaseModel *model = [[PurchaseModel alloc] init];
                model.order_id = [result stringForColumn:@"id"];
                model.package_id = [result stringForColumn:@"package_id"];
                model.total_fee = [result stringForColumn:@"total_fee"];
                model.transaction_id = [result stringForColumn:@"transaction_id"];
                
                NSLog(@"查询数据库 ---> %@ -- %@", model.order_id, model.package_id);
                [downloadArray addObject:model];
            }
        }
    }
    else {
        NSLog(@"查 - 打开数据库失败");
    }
    [self.dataBase close];
    
    return downloadArray;
}

- (BOOL)queryExistOrderData:(NSString *)orderId { //查询单条
    
    FMResultSet *result = [self.dataBase executeQuery:@"select * from purchase_table where id = ?",orderId];
    if ([result next]) {
        BOOL isPayed = [result boolForColumn:@"transaction_id"];
        return isPayed;
    }
    else {
        return NO;
    }
}

@end
