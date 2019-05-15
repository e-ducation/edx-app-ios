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

@interface TDVipPackageView () <UITableViewDataSource>

@property (nonatomic,strong) TDVipPackageHeaderView *packageHeaderView;

@end

@implementation TDVipPackageView

- (instancetype)init {
    self = [super init];
    if (self) {
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
    
    [cell.bgButton addTarget:self action:@selector(bgButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    if (self.vipID.length == 0) {
        cell.isSelect = indexPath.section == 0;
    }
    else {
        cell.isSelect = [[model.id stringValue] isEqualToString:self.vipID];
    }
    
    cell.model = model;
    
    return cell;
}

- (void)bgButtonAction:(UIButton *)sender { //选择套餐
    
    TDVipPackageModel *model = self.vipArray[sender.tag];
    self.vipID = [model.id stringValue];
    [self.tableView reloadData];
    
    [self.delegate appApproveProgress:model];
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
    
    self.packageHeaderView = [[TDVipPackageHeaderView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, 139)];
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
