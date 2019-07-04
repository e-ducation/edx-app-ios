//
//  TDVipPackageViewController.m
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDVipPackageViewController.h"
#import "TDVipPackageView.h"
#import "OEXConfig.h"
#import <AFNetworking/AFNetworking.h>
#import "OEXAuthentication.h"

#import "TDVipMessageModel.h"
#import "TDVipPackageModel.h"
#import "PurchaseManager.h"

#import "NSDictionary+OEXEncoding.h"
#import "edX-Swift.h"

@interface TDVipPackageViewController () <UITableViewDelegate,TDVipPayDelegate,TDPurchaseDelegate>

@property (nonatomic,strong) LoadStateViewController *loadController;

@property (nonatomic,strong) TDVipPackageView *packageView;
@property (nonatomic,strong) TDVipMessageModel *messageModel;

@property (nonatomic,strong) NSMutableArray *vipArray;
@property (nonatomic,strong) NSString *orderID;

@property (nonatomic,strong) PurchaseManager *purchaseManager;//内购工具类
@property (nonatomic,strong) PurchaseModel *purchaseModel;

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
    
    self.navigationItem.title = Strings.membership;
    [self setViewConstraint];
    [self getVipData:YES];
    
    self.loadController = [[LoadStateViewController alloc] init];
    [self.loadController setupInControllerWithController:self contentView:self.packageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)purchaseAction { //内购初始化
    
    self.purchaseModel = [[PurchaseModel alloc] init];
    
    self.purchaseManager = [[PurchaseManager alloc] init];
    self.purchaseManager.username = self.username;
    self.purchaseManager.delegate = self;
    self.purchaseManager.viewController = self;
    
//    WS(weakSelf);
//    [self.purchaseManager showPurchaseComplete:^(BOOL approveSucess) {
//        weakSelf.packageView.approveSucess = approveSucess;
////        weakSelf.packageView.approveSucess = YES;
//    }];
}

#pragma mark - data
- (void)getVipData:(BOOL)isFirst { //获取vip信息
    
    if (!isFirst) {
        [self showLoading:[Strings refreshingData]];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *authent = [OEXAuthentication authHeaderForApiAccess];
    [manager.requestSerializer setValue:authent forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"openedx-language-preference=%@",[NSLocale currentLocale].languageCode] forHTTPHeaderField:@"Cookie"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",ELITEU_URL,VIP_INFO_URL];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"VIP数据：%@",responseObject);
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
            
            if (isFirst) {
                //有数据了才有内购
                [self purchaseAction];
            }
        }
        
        if (isFirst) {
            [self.loadController loadViewStateWithStatus:1 error:nil];
        }
        else {
            [SVProgressHUD dismiss];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"VIP请求失败：%@",error);
        if (isFirst) {
            [self.loadController loadViewStateWithStatus:2 error:error];
        }
        else {
            [SVProgressHUD dismiss];
        }
    }];
}

//创建内购订单
- (void)createINPurchaseOrder:(NSString *)packageId statusStr:(NSString *)statusStr completion:(void(^)(void))completion {
    
    [self showLoading:statusStr];
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:packageId forKey:@"package_id"];
    
    NSString *body = [dict oex_stringByUsingFormEncoding];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:[sessionConfig defaultHTTPHeaders]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ELITEU_URL, VIP_CTEATE_INPURCHASE_ORDER]]];
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
            NSLog(@"内购订单 ----->> %@",dictionary);
            
            if ([[dictionary allKeys] containsObject:@"order_id"]) {
                self.orderID = dictionary[@"order_id"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
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
        [SVProgressHUD dismiss];
        [self.view makeToast:[Strings paymentFalied] duration:1.08 position:CSToastPositionCenter];
    });
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
- (void)appApproveProgress:(TDVipPackageModel *)model { //选择内购
    
    WS(weakSelf);
    [self createINPurchaseOrder:[model.id stringValue] statusStr:[Strings payingIap] completion:^{
        weakSelf.purchaseModel.order_id = weakSelf.orderID;
        weakSelf.purchaseModel.total_fee = model.price;
        weakSelf.purchaseModel.package_id = [model.id stringValue];
        weakSelf.purchaseManager.model = weakSelf.purchaseModel;
        
        [weakSelf appInPurchaseAction:model.price];
    }];
}

- (void)appInPurchaseAction:(NSString *)total_fee { //苹果内购
    
    int payType = 1;
    switch ([total_fee intValue]) {
        case 198:
            payType = IAP_198;
            break;
        case 488:
            payType = IAP_488;
            break;
        case 898:
            payType = IAP_898;
            break;
        case 1198:
            payType = IAP_1198;
            break;
        default:
            payType = IAP_198;
            break;
    }
    [self.purchaseManager reqToUpMoneyFromApple:payType];
}

- (void)showLoading:(NSString *)status {
    [SVProgressHUD showWithStatus:status];
    SVProgressHUD.defaultMaskType = SVProgressHUDMaskTypeBlack;
    SVProgressHUD.defaultStyle = SVProgressHUDAnimationTypeNative;
}

#pragma mark - TDPurchaseDelegate
- (void)updatedTransactionReceiveStr:(NSString *)receiveStr {
    NSLog(@"开始验证票据 -->> %@",receiveStr);
    [self showLoading:[Strings payingNow]];
    self.purchaseModel.apple_receipt = receiveStr;
    [self verrifiedAppStoreReceipt];
}

- (void)updatedLostOrderVertified:(PurchaseModel *)model {
//    NSLog(@"掉单验证票据 -->> %@",model.apple_receipt);
    [self showLoading:[Strings recoveringOrder]];
    self.purchaseModel = model;
    [self verrifiedAppStoreReceipt];
}

- (void)newOrderPrice:(int)price transactionReceiveStr:(NSString *)receiveStr {
    
    if (self.vipArray.count > 0) {
        TDVipPackageModel *vipModel;
        for (TDVipPackageModel *model in self.vipArray) {
            if ([model.price intValue] == price) {
                vipModel = model;
            }
        }
        
        if (vipModel != nil) {
            WS(weakSelf);
            [self createINPurchaseOrder:[vipModel.id stringValue] statusStr:[Strings recoveringOrder] completion:^{
                weakSelf.purchaseModel.order_id = weakSelf.orderID;
                weakSelf.purchaseModel.total_fee = vipModel.price;
                weakSelf.purchaseModel.package_id = [vipModel.id stringValue];
                weakSelf.purchaseModel.apple_receipt = receiveStr;
                weakSelf.purchaseManager.model = weakSelf.purchaseModel;
                
                [self verrifiedAppStoreReceipt];
            }];
        }
    }
}

- (void)transactionPaymentFailed {
    [self deleteOrderData];
}

- (void)verrifiedAppStoreReceipt {
    
    WS(weakSelf);
    [self.purchaseManager verificationAction:self.purchaseModel completion:^(BOOL isSuccess) {
        [self deleteOrderData];
        if (isSuccess) {
            [weakSelf vipBuySuceess];
            [weakSelf getVipData:NO];
        }
        else {
            [weakSelf.view makeToast:[Strings paymentFailedPurchase] duration:1.08 position:CSToastPositionCenter];
        }
    }];
}

- (void)deleteOrderData {
    [SVProgressHUD dismiss];
    [self.purchaseManager deleteAllIAPOrderData];//删除订单信息
}

- (void)vipBuySuceess {
    if (self.vipBuySuccessHandle) {
        self.vipBuySuccessHandle();
    }
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
