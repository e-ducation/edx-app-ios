//
//  TDVipPackageView.m
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDVipPackageView.h"
#import "TDVipPackageCell.h"
#import "TDVipPackageHeaderView.h"
#import "TDPaySheetView.h"

@interface TDVipPackageView () <UITableViewDataSource>

@property (nonatomic,strong) TDVipPackageHeaderView *packageHeaderView;
@property (nonatomic,strong) TDPaySheetView *sheetView;

@property (nonatomic,assign) NSInteger selectRow;
@property (nonatomic,assign) NSInteger payType;

@end

@implementation TDVipPackageView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectRow = 0;
        self.payType = 0;
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.vipArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TDVipPackageModel *model = self.vipArray[indexPath.section];
    
    TDVipPackageCell *cell = [[TDVipPackageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDVipPackageCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.bgButton.tag = indexPath.section;
    
    if (self.vipID.length > 0) {
        cell.isSelect = [[model.id stringValue] isEqualToString:self.vipID];
    }
    else {
      cell.isSelect = indexPath.section == self.selectRow;
    }
    
    [cell.bgButton addTarget:self action:@selector(bgButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.model = model;
    
    return cell;
}

- (void)bgButtonAction:(UIButton *)sender { //选择套餐
    
    self.vipID = nil;
    self.selectRow = sender.tag;
    [self.tableView reloadData];
    
    UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    self.sheetView = [[TDPaySheetView alloc] init];
    [self.sheetView showSheetAnimation:88.00];
    [view addSubview:self.sheetView];
    
    [self.sheetView.payButton addTarget:self action:@selector(payButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetView.wechatView.selectButton addTarget:self action:@selector(wechatButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetView.aliPayView.selectButton addTarget:self action:@selector(alipayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.sheetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(view);
    }];
}

- (void)payButtonAction:(UIButton *)sender { //支付
    [self.delegate gotoPayByType:self.payType price:@"0.00"];
}

- (void)wechatButtonAction:(UIButton *)sender { //微信
    self.payType = 0;
    [self.sheetView selectPayStyle:0];
}

- (void)alipayButtonAction:(UIButton *)sender { //支付宝
    self.payType = 1;
    [self.sheetView selectPayStyle:1];
}

- (void)vipPaySheetViewDisapear { //收回支付页面
    [self.sheetView sheetDisapear];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    self.packageHeaderView = [[TDVipPackageHeaderView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, 133)];
    self.tableView.tableHeaderView = self.packageHeaderView;
    
    TDVipMessageModel *model = [[TDVipMessageModel alloc] init];
    model.is_vip = @"0";
    [self.packageHeaderView packageViewMessage:model];
}

- (void)setMessageModel:(TDVipMessageModel *)messageModel {
    _messageModel = messageModel;
    
    [self.packageHeaderView packageViewMessage:messageModel];
}

- (void)setVipArray:(NSArray *)vipArray {
    _vipArray = vipArray;
    
    [self.tableView reloadData];
}

@end
