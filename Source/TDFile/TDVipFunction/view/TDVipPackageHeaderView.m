//
//  TDVipPackageHeaderView.m
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDVipPackageHeaderView.h"
#import "edX-Swift.h"

@interface TDVipPackageHeaderView ()

@property (nonatomic,strong) UIImageView *bgImageView;
@property (nonatomic,strong) UIButton *bgButton;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *remindLabel;
@property (nonatomic,strong) UILabel *messageLabel;
@property (nonatomic,strong) UILabel *startLabel;
@property (nonatomic,strong) UILabel *endLabel;

@end

@implementation TDVipPackageHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - UI
- (void)configView {
    self.bgImageView = [[UIImageView alloc] init];
    self.bgImageView.image = [UIImage imageNamed:@"vip_bg_image"];
    self.bgImageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:self.bgImageView];
    
    self.bgButton = [[UIButton alloc] init];
    self.bgButton.showsTouchWhenHighlighted = YES;
    [self.bgButton setBackgroundImage:[UIImage imageNamed:@"vip_message"] forState:UIControlStateNormal];
    [self.bgImageView addSubview:self.bgButton];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"#4788c7"];
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    [self.bgButton addSubview:self.titleLabel];
    
    self.remindLabel = [[UILabel alloc] init];
    self.remindLabel.numberOfLines = 0;
    self.remindLabel.textAlignment = NSTextAlignmentCenter;
    self.remindLabel.textColor = [UIColor colorWithHexString:@"#656d78"];
    self.remindLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self.bgButton addSubview:self.remindLabel];
    
    self.startLabel = [[UILabel alloc] init];
    self.startLabel.textColor = [UIColor colorWithHexString:@"#aab2bd"];
    self.startLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.bgButton addSubview:self.startLabel];
    
    self.endLabel = [[UILabel alloc] init];
    self.endLabel.textColor = [UIColor colorWithHexString:@"#aab2bd"];
    self.endLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.bgButton addSubview:self.endLabel];
    
    self.titleLabel.text = [Strings elitembaVipMember];
    self.remindLabel.text = [Strings vipMemberWatchFree]; //已开通1天 剩余 364天//会员已过期1天
    self.startLabel.text = [NSString stringWithFormat:@"%@2018-1-2",[Strings lastOpend]];
    self.endLabel.text = [NSString stringWithFormat:@"%@2019-1-1",[Strings edpireOn]];
    
}

- (void)setViewConstraint {
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgImageView.mas_left).offset(13);
        make.right.mas_equalTo(self.bgImageView.mas_right).offset(-13);
        make.top.mas_equalTo(self.bgImageView.mas_top).offset(14);
        make.bottom.mas_equalTo(self.bgImageView.mas_bottom).offset(-17);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgButton.mas_top).offset(13);
        make.left.mas_equalTo(self.bgButton.mas_left).offset(22);
        make.height.mas_equalTo(23);
    }];
    
    [self.startLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.bottom.mas_equalTo(self.bgButton.mas_bottom).offset(-12);
        make.height.mas_equalTo(17);
    }];
    
    [self.endLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgButton.mas_right).offset(-22);
        make.bottom.mas_equalTo(self.startLabel.mas_bottom);
        make.height.mas_equalTo(17);
    }];
    
    [self.remindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgButton.mas_left).offset(22);
        make.right.mas_equalTo(self.bgButton.mas_right).offset(-22);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(5);
    }];
}

#pragma mark - Action
/**
 VIP信息数据
 @param type 0 未购买，1 已购买，2 已过期
 */
- (void)packageViewMessage:(TDVipMessageModel *)messageModel {
    
    NSInteger type = 0;
    if ([messageModel.is_vip boolValue]) {
        type = 1;
    }
    else {
        if (messageModel.last_start_at.length > 0) {
            type = 2;
        }
    }
    
    switch (type) {
        case 0:
            self.remindLabel.text = [Strings vipMemberWatchFree];
            break;
        case 1:
            [self setDateStr:[messageModel.vip_remain_days stringValue] pastStr:[messageModel.vip_pass_days stringValue] type:1];
            self.startLabel.text = [NSString stringWithFormat:@"%@%@",[Strings opendOn],messageModel.start_at];
            self.endLabel.text = [NSString stringWithFormat:@"%@%@",[Strings edpireOn],messageModel.expired_at];
            break;
        default:
            [self setDateStr:[messageModel.vip_expired_days stringValue] pastStr:0 type:2];
            self.startLabel.text = [NSString stringWithFormat:@"%@%@",[Strings lastOpend],messageModel.last_start_at];
            self.endLabel.text = [NSString stringWithFormat:@"%@%@",[Strings edpireOn],messageModel.expired_at];
            break;
    }
    
    self.startLabel.hidden = type == 0;
    self.endLabel.hidden = type == 0;
    self.remindLabel.textAlignment = type == 0 ? NSTextAlignmentLeft : NSTextAlignmentCenter;
}

- (void)setDateStr:(NSString *)validStr pastStr:(NSString *)pastStr type:(NSInteger)type {
    NSString *str;
    if (type == 1) {
        str = [Strings opneDayLeftWithDay:validStr];
    }
    else {
      str = [Strings vipExpiredDayWithDay:validStr];
    }
    
    NSRange range = [str rangeOfString:validStr];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:24] range:range];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:type == 1 ? @"#4788c7" : @"#fa7f2b"] range:range];
    self.remindLabel.attributedText = attStr;
}

@end
