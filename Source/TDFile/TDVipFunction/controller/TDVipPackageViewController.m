//
//  TDVipPackageViewController.m
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDVipPackageViewController.h"
#import "TDVipPackageView.h"
#import "TDWechatManager.h"
#import "TDAlipayManager.h"
#import "OEXConfig.h"
#import <AFNetworking/AFNetworking.h>
#import "OEXAuthentication.h"

#import "TDVipMessageModel.h"
#import "TDVipPackageModel.h"
#import "TDAliPayModel.h"

#import "NSDictionary+OEXEncoding.h"
#import "edX-Swift.h"

@interface TDVipPackageViewController () <UITableViewDelegate, TDVipPayDelegate, TDAlipayDelegate, TDWXDelegate>

@property (nonatomic,strong) LoadStateViewController *loadController;

@property (nonatomic,strong) TDVipPackageView *packageView;
@property (nonatomic,strong) TDVipMessageModel *messageModel;

@property (nonatomic,strong) NSMutableArray *vipArray;
@property (nonatomic,strong) NSString *orderID;

@end

@implementation TDVipPackageViewController

- (NSMutableArray *)vipArray {
    if (!_vipArray) {
        _vipArray = [[NSMutableArray alloc] init];
    }
    return _vipArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"VIP";
    [self setViewConstraint];
    [self getVipData];
    
    self.loadController = [[LoadStateViewController alloc] init];
    [self.loadController setupInControllerWithController:self contentView:self.packageView];
}

#pragma mark - data
- (void)getVipData { //获取vip信息
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *authent = [OEXAuthentication authHeaderForApiAccess];
    [manager.requestSerializer setValue:authent forHTTPHeaderField:@"Authorization"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",ELITEU_URL,VIP_INFO_URL];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        NSLog(@"VIP数据：%@",responseObject);
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        
        if ([[responseDic allKeys] containsObject:@"extra"]) {
            NSDictionary *extra = responseDic[@"extra"];
            self.messageModel = [[TDVipMessageModel alloc] initWithInfo:extra];
            self.packageView.messageModel = self.messageModel;
        }
        
        if ([[responseDic allKeys] containsObject:@"results"]) {
            if (self.vipArray.count > 0) {
                [self.vipArray removeAllObjects];
            }
            NSArray *results = responseDic[@"results"];
            for (NSDictionary *dic in results) {
                TDVipPackageModel *vipModel = [[TDVipPackageModel alloc] initWithInfo:dic];
                [self.vipArray addObject:vipModel];
            }
            self.packageView.vipArray = self.vipArray;
        }
        
        [self.loadController loadViewStateWithStatus:1 error:nil];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"VIP请求失败：%@",error);
        [self.loadController loadViewStateWithStatus:2 error:error];
    }];
}

//创建支付宝订单
- (void)createAlipayOrder:(NSString *)packageId completion:(void(^)(NSString *orderString))completion {
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:packageId forKey:@"package_id"];
    
    NSString *body = [dict oex_stringByUsingFormEncoding];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:[sessionConfig defaultHTTPHeaders]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ELITEU_URL, VIP_CTEATE_ALIPAY_ORDER]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString* authValue = [OEXAuthentication authHeaderForApiAccess];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
        if(httpResp.statusCode == 200) {
            NSError* error;
            NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"----->> %@",dictionary);
            
            if ([[dictionary allKeys] containsObject:@"alipay_request"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.orderID = dictionary[@"order_id"];
                    NSString *str = dictionary[@"alipay_request"];
                    completion(str);
                });
            }
            else {
                [self createOrderFailed];
            }
        }
        else {
            [self createOrderFailed];
        }
    }]resume];
}

//创建微信订单
- (void)createWechatOrder:(NSString *)packageId completion:(void(^)(weChatParamsItem *item))completion {
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:packageId forKey:@"package_id"];
    
    NSString *body = [dict oex_stringByUsingFormEncoding];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:[sessionConfig defaultHTTPHeaders]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ELITEU_URL, VIP_CTEATE_WECHAT_ORDER]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString* authValue = [OEXAuthentication authHeaderForApiAccess];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
        if(httpResp.statusCode == 200) {
            NSError* error;
            NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"----->> %@",dictionary);
            
            if ([[dictionary allKeys] containsObject:@"wechat_request"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.orderID = dictionary[@"order_id"];
                    NSDictionary *orderDic = dictionary[@"wechat_request"];
                    weChatParamsItem *item = [[weChatParamsItem alloc] initWithOroderDic:orderDic];
                    completion(item);
                });
            }
            else {
                [self createOrderFailed];
            }
        }
        else {
            [self createOrderFailed];
        }
    }]resume];
}

- (void)createOrderFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.packageView vipPaySheetViewDisapear];
        [self.view makeToast:@"订单创建失败" duration:1.08 position:CSToastPositionCenter];
    });
}

//查询订单
- (void)queryOrderStatus:(NSString *)orderID request:(NSInteger)num {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *authent = [OEXAuthentication authHeaderForApiAccess];
    [manager.requestSerializer setValue:authent forHTTPHeaderField:@"Authorization"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@",ELITEU_URL,VIP_ORDER_STATUS_URL,orderID];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"VIP数据：%@",responseObject);
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        if ([code intValue] == 0) {
            //1: 等待支付, 2: 已完成, 3: 已取消, 4: 已退款, 0: 查询失败
            NSInteger status = [responseDic[@"data"][@"status"] integerValue];
            if (status == 0 || status == 1) {
                [self requestMore:orderID request:num];
            }
            else if (status == 2) {
                [self.packageView vipPaySheetViewDisapear];
                [self getVipData]; //刷新数据
            }
            else {
                [self.packageView vipPaySheetViewDisapear];
                [self.view makeToast:@"订单更新失败" duration:0.8 position:CSToastPositionCenter];
            }
        }
        else {
            [self requestMore:orderID request:num];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"VIP请求失败：%@",error);
        [self requestMore:orderID request:num];
    }];
}

- (void)requestMore:(NSString *)orderID request:(NSInteger)num {
    [self.packageView vipPaySheetViewDisapear];
    if (num == 0) {
        [self queryOrderStatus:orderID request:1];
    }
    else {
        [self.view makeToast:@"查询订单失败" duration:0.8 position:CSToastPositionCenter];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 17;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

#pragma mark - TDVipPayDelegate
- (void)gotoPayByType:(NSInteger)type vipID:(NSString *)vipID {//支付 0 微信，1 支付宝
    
    WS(weakSelf);
    if (type == 0) {
        NSLog(@"微信支付");
        [self createWechatOrder:vipID completion:^(weChatParamsItem *item) {
            [weakSelf wechatPayAction:item];
        }];
    }
    else {
        NSLog(@"支付宝支付");
        
        [self createAlipayOrder:vipID completion:^(NSString *orderString) {
            [weakSelf alipayAction:orderString];
        }];
    }
}

- (void)wechatPayAction:(weChatParamsItem *)item { //微信支付
    TDWechatManager *manager = [TDWechatManager shareManager];
    manager.delegate = self;
    [manager submitPostWechatPay:item];
}

- (void)alipayAction:(NSString *)orderString { //支付宝支付
    TDAlipayManager *alipayManager = [TDAlipayManager shareManager];
    alipayManager.delegate = self;
    [alipayManager sumbmitAliPay:orderString];
}

#pragma mark - TDWXDelegate
- (void)weixinPaySuccessHandle {//支付成功
    NSLog(@"支付宝 -- 支付成功");
    [self queryOrderStatus:self.orderID request:0];
}

- (void)weixinPayFailed:(NSInteger)status {//支付失败
    NSLog(@"支付宝 -- 支付失败");
    [self.packageView vipPaySheetViewDisapear];
}

#pragma mark - TDAlipayDelegate
- (void)alipaySuccessHandle { //支付成功
    NSLog(@"支付宝 -- 支付成功");
    [self queryOrderStatus:self.orderID request:0];
}

- (void)alipayFaile:(NSInteger)status { //支付失败
    NSLog(@"支付宝 -- 支付失败");
    [self.packageView vipPaySheetViewDisapear];
}

#pragma mark - UI
- (void)setViewConstraint {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.packageView = [[TDVipPackageView alloc] init];
    self.packageView.tableView.delegate = self;
    self.packageView.delegate = self;
    self.packageView.vipID = self.vipID;
    [self.view addSubview:self.packageView];
    
    [self.packageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}


@end
