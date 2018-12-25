//
//  TDVipAlertView.m
//  edX
//
//  Created by Elite Edu on 2018/12/11.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDVipAlertView.h"
#import "edX-Swift.h"

@interface TDVipAlertView ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIView *alertView;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *messageLabel;
@property (nonatomic,strong) UILabel *line;

@end

@implementation TDVipAlertView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - Action
//- (void)cancelButtonAction:(UIButton *)sender {
//    [self removeFromSuperview];
//}

//- (void)sureButtonAction:(UIButton *)sender {
//    [self removeFromSuperview];
//}

- (void)tapAction:(UITapGestureRecognizer *)sender {
    [self removeFromSuperview];
}

#pragma mark - UI
- (void)configView {
    self.bgView = [[UIView alloc] init];
    self.bgView.userInteractionEnabled = YES;
    self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self addSubview:self.bgView];
    
    self.alertView = [[UIView alloc] init];
    self.alertView.backgroundColor = [UIColor whiteColor];
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 6.0;
    self.alertView.clipsToBounds = YES;
    self.alertView.userInteractionEnabled = YES;
    [self addSubview:self.alertView];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"vip_alert_mage"];
    [self.alertView addSubview:self.imageView];
    
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.textColor = [UIColor colorWithHexString:@"#6e6e6e"];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    [self.alertView addSubview:self.messageLabel];
    
    self.cancelButton = [[UIButton alloc] init];
    self.cancelButton.backgroundColor = [UIColor whiteColor];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    [self.cancelButton setTitleColor:[UIColor colorWithHexString:@"#b6b6b6"] forState:UIControlStateNormal];
//    [self.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView addSubview:self.cancelButton];
    
    self.sureButton = [[UIButton alloc] init];
    self.sureButton.backgroundColor = [UIColor colorWithHexString:@"#4788c7"];
    self.sureButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    [self.sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.sureButton addTarget:self action:@selector(sureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView addSubview:self.sureButton];
    
    self.line = [[UILabel alloc] init];
    self.line.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    [self.alertView addSubview:self.line];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.bgView addGestureRecognizer:tap];
    
    [self.cancelButton setTitle:[Strings vipNo] forState:UIControlStateNormal];
    [self.sureButton setTitle:[Strings vipYex] forState:UIControlStateNormal];
    
    NSString *str = [Strings elitembaCourse];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
    UIColor *color = [UIColor colorWithHexString:@"#3288cc"];
    NSRange messageRange = [str rangeOfString:[Strings learnCourseFree]];
    NSRange ylRange = [str rangeOfString:[Strings elitembaVip]];
    [attStr addAttributes:@{NSForegroundColorAttributeName:color} range:messageRange];
    [attStr addAttribute:NSForegroundColorAttributeName value:color range:ylRange];
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    [para setLineSpacing:5];
    [attStr addAttribute:NSParagraphStyleAttributeName value:para range:NSMakeRange(0, str.length)];
    
    self.messageLabel.attributedText = attStr;
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(TDWidth * 0.77, 288));
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.alertView.mas_top);
        make.centerX.mas_equalTo(self.alertView.mas_centerX);
        make.height.mas_equalTo(90);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.alertView);
        make.bottom.mas_equalTo(self.alertView.mas_bottom).offset(-43);
        make.height.mas_equalTo(1);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(self.alertView);
        make.top.mas_equalTo(self.line.mas_bottom);
        make.width.mas_equalTo((TDWidth - 88)/2);
    }];
    
    [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(self.alertView);
        make.top.mas_equalTo(self.line.mas_bottom);
        make.width.mas_equalTo(self.cancelButton.mas_width);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.alertView.mas_left).offset(28);
        make.right.mas_equalTo(self.alertView.mas_right).offset(-28);
        make.top.mas_equalTo(self.imageView.mas_bottom).offset(0);
        make.bottom.mas_equalTo(self.line.mas_top).offset(-0);
    }];
}

@end
