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

- (void)createOrder:(NSString *)packageId completion:(void(^)(TDAliPayModel *model))completion {
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:packageId forKey:@"package_id"];
    
    NSString *body = [dict oex_stringByUsingFormEncoding];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:[sessionConfig defaultHTTPHeaders]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ELITEU_URL, VIP_CTEATE_ORDER_URL]]];
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
            
            if ([[dictionary allKeys] containsObject:@"data_url"]) {
                NSDictionary *orderDic = dictionary[@"data_url"];
                TDAliPayModel *alipayModel = [[TDAliPayModel alloc] initWithOrder:orderDic];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(alipayModel);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        }
    }]resume];
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
    
    if (type == 0) {
        NSLog(@"微信支付");
        [self wechatPayAction];
    }
    else {
        NSLog(@"支付宝支付");
        WS(weakSelf);
        [self createOrder:vipID completion:^(TDAliPayModel *model) {
            [weakSelf alipayAction:model];
        }];
    }
}

- (void)wechatPayAction { //微信支付
    weChatParamsItem *item = [[weChatParamsItem alloc] init];
    item.appid = [[OEXConfig sharedConfig] weixinAPPID];
    item.mch_id = @"";
    item.nonce_str = @"";
    item.prepay_id = @"";
    item.sign = @"";
    
    TDWechatManager *manager = [TDWechatManager shareManager];
    manager.delegate = self;
    [manager submitPostWechatPay:item];
}

- (void)alipayAction:(TDAliPayModel *)aliPayModel {//支付宝支付
    TDAlipayManager *alipayManager = [TDAlipayManager shareManager];
    alipayManager.delegate = self;
    [alipayManager sumbmitAliPay:aliPayModel];
}

#pragma mark - TDWXDelegate
- (void)weixinPaySuccessHandle {//支付成功
    NSLog(@"支付宝 -- 支付成功");
    [self.packageView vipPaySheetViewDisapear];
}

- (void)weixinPayFailed:(NSInteger)status {//支付失败
    NSLog(@"支付宝 -- 支付失败");
    [self.packageView vipPaySheetViewDisapear];
}

#pragma mark - TDAlipayDelegate
- (void)alipaySuccessHandle { //支付成功
    NSLog(@"支付宝 -- 支付成功");
    [self.packageView vipPaySheetViewDisapear];
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
