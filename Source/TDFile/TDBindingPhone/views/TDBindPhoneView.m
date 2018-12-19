//
//  TDBindPhoneView.m
//  edX
//
//  Created by Elite Edu on 2018/12/12.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDBindPhoneView.h"

@interface TDBindPhoneView ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIView *phoneView;
@property (nonatomic,strong) UIView *codeView;
@property (nonatomic,strong) UIButton *areaButton;
@property (nonatomic,strong) UILabel *line;

@end

@implementation TDBindPhoneView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.phoneText resignFirstResponder];
    [self.codeText resignFirstResponder];
}

- (void)configView {
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    self.phoneView = [[UIView alloc] init];
    self.phoneView.backgroundColor = [UIColor colorWithHexString:@"#f5f7fa"];
    self.phoneView.layer.masksToBounds = YES;
    self.phoneView.layer.cornerRadius = 4.0;
    [self.bgView addSubview:self.phoneView];
    
    self.codeView = [[UIView alloc] init];
    self.codeView.backgroundColor = [UIColor colorWithHexString:@"#f5f7fa"];
    self.codeView.layer.masksToBounds = YES;
    self.codeView.layer.cornerRadius = 4.0;
    [self.bgView addSubview:self.codeView];
    
    self.areaButton = [[UIButton alloc] init];
    self.areaButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self.areaButton setTitleColor:[UIColor colorWithHexString:@"#2e313c"] forState:UIControlStateNormal];
    [self.phoneView addSubview:self.areaButton];
    
    self.line = [[UILabel alloc] init];
    self.line.backgroundColor = [UIColor colorWithHexString:@"#bfc1c9"];
    [self.phoneView addSubview:self.line];
    
    self.phoneText = [[UITextField alloc] init];
    self.phoneText.returnKeyType = UIReturnKeyNext;
    self.phoneText.keyboardType = UIKeyboardTypePhonePad;
    self.phoneText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    self.phoneText.textColor = [UIColor colorWithHexString:@"#2e313c"];
    [self.phoneView addSubview:self.phoneText];
    
    self.codeText = [[UITextField alloc] init];
    self.codeText.returnKeyType = UIReturnKeySend;
    self.codeText.keyboardType = UIKeyboardTypeASCIICapable;
    self.codeText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    self.codeText.textColor = [UIColor colorWithHexString:@"#2e313c"];
    [self.codeView addSubview:self.codeText];
    
    self.sendButton = [[UIButton alloc] init];
    self.sendButton.layer.cornerRadius = 4.0;
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    self.sendButton.backgroundColor = [UIColor colorWithHexString:@"#d3d3d3"];
    [self.codeView addSubview:self.sendButton];
    
    self.handinButton = [[UIButton alloc] init];
    self.handinButton.layer.cornerRadius = 4.0;
    self.handinButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    self.handinButton.backgroundColor = [UIColor colorWithHexString:@"#d3d3d3"];
    [self.bgView addSubview:self.handinButton];
    
    self.sendButton.userInteractionEnabled = NO;
    self.handinButton.userInteractionEnabled = NO;
    
    self.phoneText.placeholder = @"请输入手机号";
    self.codeText.placeholder = @"请输入验证码";
    [self.sendButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.handinButton setTitle:@"提交" forState:UIControlStateNormal];
    [self.areaButton setTitle:@"+86" forState:UIControlStateNormal];
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(33);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-33);
        make.top.mas_equalTo(self.bgView.mas_top).offset(28);
        make.height.mas_equalTo(41);
    }];
    
    [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.phoneView.mas_left);
        make.right.mas_equalTo(self.phoneView.mas_right);
        make.top.mas_equalTo(self.phoneView.mas_bottom).offset(18);
        make.height.mas_equalTo(41);
    }];
    
    [self.areaButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.phoneView.mas_left);
        make.top.bottom.mas_equalTo(self.phoneView);
        make.width.mas_equalTo(60);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.areaButton.mas_right);
        make.centerY.mas_equalTo(self.phoneView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(1, 22));
    }];
    
    [self.phoneText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.line.mas_right).offset(12);
        make.top.bottom.right.mas_equalTo(self.phoneView);
    }];
    
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.codeView.mas_right).offset(-10);
        make.centerY.mas_equalTo(self.codeView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(74, 28));
    }];
    
    [self.codeText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.codeView.mas_left).offset(10);
        make.right.mas_equalTo(self.sendButton.mas_left).offset(-8);
        make.top.bottom.mas_equalTo(self.codeView);
    }];
    
    [self.handinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.phoneView.mas_left);
        make.right.mas_equalTo(self.phoneView.mas_right);
        make.top.mas_equalTo(self.codeView.mas_bottom).offset(35);
        make.height.mas_equalTo(41);
    }];
}

@end
