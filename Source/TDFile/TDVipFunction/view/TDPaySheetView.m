//
//  TDPaySheetView.m
//  edX
//
//  Created by Elite Edu on 2018/12/3.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDPaySheetView.h"
#import "edX-Swift.h"

static NSInteger height = 230;

@interface TDPaySheetView ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIView *sheetView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *payLabel;
@property (nonatomic,strong) UILabel *priceLabel;


@end

@implementation TDPaySheetView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configeView];
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - UI
- (void)configeView {
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    [self addSubview:self.bgView];
    
    self.sheetView = [[UIView alloc] init];
    self.sheetView.backgroundColor = [UIColor colorWithHexString:@"#f5f7fa"];
    [self addSubview:self.sheetView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"#2e313c"];
    [self.sheetView addSubview:self.titleLabel];
    
    self.payLabel = [[UILabel alloc] init];
    self.payLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    self.payLabel.textColor = [UIColor colorWithHexString:@"#747d8c"];
    [self.sheetView addSubview:self.payLabel];
    
    self.priceLabel = [[UILabel alloc] init];
    self.priceLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:24];
    self.priceLabel.textColor = [UIColor colorWithHexString:@"#fa7f2b"];
    [self.sheetView addSubview:self.priceLabel];
    
    self.payButton = [[SpinnerButton alloc] init];
    self.payButton.backgroundColor = [UIColor colorWithHexString:@"#fc9753"];
    [self.sheetView addSubview:self.payButton];
  
    self.wechatView = [[TDPayView alloc] initWithType:0];
    [self.sheetView addSubview:self.wechatView];
    
    self.aliPayView = [[TDPayView alloc] initWithType:1];
    [self.sheetView addSubview:self.aliPayView];
    
    [self.payButton setTitle:[Strings sumitPayment] forState:UIControlStateNormal];
    self.titleLabel.text = [Strings choosePaymentMethod];
    self.payLabel.text = [Strings paymentNum];
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"0.00"];
    [attStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:14] range:NSMakeRange(attStr.length - 2, 2)];
    self.priceLabel.attributedText = attStr;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    self.bgView.userInteractionEnabled = YES;
    [self.bgView addGestureRecognizer:tap];
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    self.sheetView.frame = CGRectMake(0, TDHeight, TDWidth, height);
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sheetView.mas_left).offset(20);
        make.top.mas_equalTo(self.sheetView.mas_top).offset(17);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sheetView.mas_right).offset(-20);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
    }];
    
    [self.payLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.priceLabel.mas_left).offset(-8);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
    }];
    
    [self.payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.sheetView);
        make.height.mas_equalTo(49);
    }];
    
    [self.wechatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.sheetView);
        make.top.mas_equalTo(self.sheetView.mas_top).offset(53);
        make.height.mas_equalTo(64);
    }];
    
    [self.aliPayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.sheetView);
        make.top.mas_equalTo(self.wechatView.mas_bottom);
        make.bottom.mas_equalTo(self.payButton.mas_top);
    }];
}

#pragma mark - Action
- (void)showSheetAnimation:(CGFloat)price {
    
    NSString *priceStr = [NSString stringWithFormat:@"%.2f",price];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:priceStr];
    [attStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:14] range:NSMakeRange(attStr.length - 2, 2)];
    self.priceLabel.attributedText = attStr;
    
    self.wechatView.checkButton.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        self.sheetView.frame = CGRectMake(0, TDHeight - height, TDWidth, height);
    }];
}

- (void)sheetDisapear {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        self.sheetView.frame = CGRectMake(0, TDHeight, TDWidth, height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self sheetDisapear];
}

- (void)selectPayStyle:(NSInteger)type {
    
    self.wechatView.checkButton.selected = type == 0;
    self.aliPayView.checkButton.selected = (type != 0);
}

@end
