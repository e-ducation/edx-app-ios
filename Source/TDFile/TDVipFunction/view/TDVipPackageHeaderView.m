//
//  TDVipPackageHeaderView.m
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDVipPackageHeaderView.h"

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
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
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
    
    self.titleLabel.text = @"英荔商学院VIP会员";
    self.remindLabel.text = @"开通VIP会员，可免费观看英荔商学院全部课程。"; //已开通1天 剩余 364天//会员已过期1天
    self.startLabel.text = @"上次开通日期：2018年1月2日";
    self.endLabel.text = @"到期日期：2019年1月1日";
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
    }];
    
    [self.remindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgButton.mas_left).offset(22);
        make.right.mas_equalTo(self.bgButton.mas_right).offset(-22);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(7);
    }];
    
    [self.startLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.bottom.mas_equalTo(self.bgButton.mas_bottom).offset(-12);
    }];
    
    [self.endLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgButton.mas_right).offset(-22);
        make.bottom.mas_equalTo(self.startLabel.mas_bottom);
    }];
}

#pragma mark - Action
/**
 VIP信息数据
 @param start 开始时间
 @param end 到期时间
 @param validStr 剩余多少天/已过期多少天
 @param pastStr  已过多少天
 @param type 0 未购买，1 已购买，2 已过期
 */
- (void)packageStart:(NSString *)start end:(NSString *)end validStr:(NSString *)validStr pastStr:(NSString *)pastStr type:(NSInteger)type {
    
    switch (type) {
        case 0:
            self.remindLabel.textAlignment = NSTextAlignmentLeft;
            self.remindLabel.text = @"开通VIP会员，可免费观看英荔商学院全部课程。";
            self.startLabel.hidden = YES;
            self.endLabel.hidden = YES;
            break;
        case 1:
            self.remindLabel.textAlignment = NSTextAlignmentCenter;
            [self setDateStr:validStr pastStr:pastStr type:1];
            self.startLabel.text = [NSString stringWithFormat:@"开通日期：%@",start];
            self.endLabel.text = [NSString stringWithFormat:@"到期日期：%@",end];
            break;
        default:
            self.remindLabel.textAlignment = NSTextAlignmentCenter;
            [self setDateStr:validStr pastStr:0 type:2];
            self.startLabel.text = [NSString stringWithFormat:@"上次开通日期：%@",start];
            self.endLabel.text = [NSString stringWithFormat:@"到期日期：%@",end];
            break;
    }
}

- (void)setDateStr:(NSString *)validStr pastStr:(NSString *)pastStr type:(NSInteger)type {
    NSString *str;
    if (type == 1) {
        str =  [NSString stringWithFormat:@"已开通1天 剩余%@天",validStr];
    }
    else {
      str = [NSString stringWithFormat:@"会员已过期%@天",validStr];
    }
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange range = NSMakeRange(attStr.length - validStr.length - 1, validStr.length);
    [attStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:24] range:range];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#fa7f2b"] range:range];
    self.remindLabel.attributedText = attStr;
}

@end
