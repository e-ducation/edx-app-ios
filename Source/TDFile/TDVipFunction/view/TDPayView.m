//
//  TDPayView.m
//  edX
//
//  Created by Elite Edu on 2018/12/3.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDPayView.h"
#import "edX-Swift.h"

@interface TDPayView ()

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,assign) NSInteger type;
@end

@implementation TDPayView

- (instancetype)initWithType:(NSInteger)type {
    self = [super init];
    if (self) {
        self.type = type;
        [self configeView];
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - UI
- (void)configeView {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.selectButton = [[UIButton alloc] init];
    [self addSubview:self.selectButton];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:self.type == 0 ? @"weicha_pay" : @"ali_pay"];
    [self.selectButton addSubview:self.imageView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.type == 0 ? [Strings wechatPayStyle] : [Strings alipayStyle];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"#2e313c"];
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    [self.selectButton addSubview:self.titleLabel];
    
    self.checkButton = [[UIButton alloc] init];
    self.checkButton.userInteractionEnabled = NO;
    [self.checkButton setBackgroundImage:[UIImage imageNamed:@"no_select_pay"] forState:UIControlStateNormal];
    [self.checkButton setBackgroundImage:[UIImage imageNamed:@"select_pay"] forState:UIControlStateSelected];
    [self.selectButton addSubview:self.checkButton];
}

- (void)setViewConstraint {
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.selectButton.mas_left).offset(20);
        make.centerY.mas_equalTo(self.selectButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(33, 33));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageView.mas_right).offset(22);
        make.centerY.mas_equalTo(self.imageView);
    }];
    
    [self.checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.selectButton.mas_right).offset(-28);
        make.centerY.mas_equalTo(self.imageView);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
}


@end
