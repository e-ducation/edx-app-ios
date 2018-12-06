//
//  TDVipPackageViewController.m
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDVipPackageViewController.h"
#import "TDVipPackageView.h"
#import "WeChatPay.h"
#import "OEXConfig.h"

@interface TDVipPackageViewController () <UITableViewDelegate, TDVipPayDelegate>

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
    
    weChatParamsItem *item = [[weChatParamsItem alloc] init];
    item.appid = [[OEXConfig sharedConfig] weixinAPPID];
    item.mch_id = @"";
    item.nonce_str = @"";
    item.order_id = @"";
    item.prepay_id = @"";
    item.sign = @"";
    
    WeChatPay *wechat = [[WeChatPay alloc] init];
    [wechat submitPostWechatPay:item];
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
