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

@interface TDVipPackageViewController () <UITableViewDelegate, TDVipPayDelegate, TDAlipayDelegate, TDWXDelegate>

@property (nonatomic,strong) TDVipPackageView *packageView;

@end

@implementation TDVipPackageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"VIP";
    [self setViewConstraint];
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
- (void)gotoPayByType:(NSInteger)type price:(NSString *)price {//支付
    
    if (type == 0) {
        [self wechatPayAction];
    }
    else {
        [self alipayAction];
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

- (void)alipayAction {//支付宝支付
    TDAlipayManager *alipayManager = [TDAlipayManager shareManager];
    alipayManager.delegate = self;
    
    TDAliPayModel *aliPayModel = [[TDAliPayModel alloc] init];
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
    
    self.packageView = [[TDVipPackageView alloc] init];
    self.packageView.tableView.delegate = self;
    self.packageView.delegate = self;
    [self.view addSubview:self.packageView];
    
    [self.packageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}


@end
