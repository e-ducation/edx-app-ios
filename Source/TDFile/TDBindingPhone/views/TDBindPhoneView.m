//
//  TDBindPhoneView.m
//  edX
//
//  Created by Elite Edu on 2018/12/12.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDBindPhoneView.h"
#import "edX-Swift.h"

@interface TDBindPhoneView ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIView *phoneLine;
@property (nonatomic,strong) UIView *codeLine;
@property (nonatomic,strong) UIButton *areaButton;
@property (nonatomic,strong) UILabel *line;
@property (nonatomic,strong) UILabel *titleLabel;

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
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:22];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"#2e313c"];
    [self.bgView addSubview:self.titleLabel];
    
    self.bindLabel = [[UILabel alloc] init];
    self.bindLabel.textAlignment = NSTextAlignmentCenter;
    self.bindLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    self.bindLabel.textColor = [UIColor colorWithHexString:@"#aab2bd"];
    [self.bgView addSubview:self.bindLabel];
    
    self.phoneLine = [[UIView alloc] init];
    self.phoneLine.backgroundColor = [UIColor colorWithHexString:@"#eff2f6"];
    [self.bgView addSubview:self.phoneLine];
    
    self.codeLine = [[UIView alloc] init];
    self.codeLine.backgroundColor = [UIColor colorWithHexString:@"#eff2f6"];
    [self.bgView addSubview:self.codeLine];
    
    self.areaButton = [[UIButton alloc] init];
    self.areaButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    [self.areaButton setTitleColor:[UIColor colorWithHexString:@"#2e313c"] forState:UIControlStateNormal];
    [self.bgView addSubview:self.areaButton];
    
    self.line = [[UILabel alloc] init];
    self.line.backgroundColor = [UIColor colorWithHexString:@"#bfc1c9"];
    [self.bgView addSubview:self.line];
    
    self.phoneText = [[UITextField alloc] init];
    self.phoneText.returnKeyType = UIReturnKeyNext;
    self.phoneText.keyboardType = UIKeyboardTypePhonePad;
    self.phoneText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    self.phoneText.textColor = [UIColor colorWithHexString:@"#2e313c"];
    [self.bgView addSubview:self.phoneText];
    
    self.codeText = [[UITextField alloc] init];
    self.codeText.returnKeyType = UIReturnKeySend;
    self.codeText.keyboardType = UIKeyboardTypeASCIICapable;
    self.codeText.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    self.codeText.textColor = [UIColor colorWithHexString:@"#2e313c"];
    [self.bgView addSubview:self.codeText];
    
    self.sendButton = [[UIButton alloc] init];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    [self.sendButton setTitleColor:[UIColor colorWithHexString:@"#0f80bf"] forState:UIControlStateNormal];
    [self.bgView addSubview:self.sendButton];
    
    self.handinButton = [[UIButton alloc] init];
    self.handinButton.layer.cornerRadius = 4.0;
    self.handinButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    self.handinButton.backgroundColor = [UIColor colorWithHexString:@"#d3d3d3"];
    [self.bgView addSubview:self.handinButton];
    
    self.sendButton.userInteractionEnabled = NO;
    self.handinButton.userInteractionEnabled = NO;
    
    self.titleLabel.text = [Strings bindCellphoneTitle];
    self.phoneText.placeholder = [Strings enterCellphone];
    self.codeText.placeholder = [Strings enterVerificateCode];
    [self.sendButton setTitle:[Strings getVerification] forState:UIControlStateNormal];
    [self.handinButton setTitle:[Strings submitText] forState:UIControlStateNormal];
    [self.areaButton setTitle:@"+86" forState:UIControlStateNormal];
    
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.bgView).offset(25);
        make.height.mas_equalTo(33);
    }];
    
    [self.bindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).offset(18);
        make.right.mas_equalTo(self.bgView).offset(-18);
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
    }];
    
    [self.areaButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(28);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(48);
        make.height.mas_equalTo(33);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).offset(67);
        make.centerY.mas_equalTo(self.areaButton);
        make.size.mas_equalTo(CGSizeMake(1, 22));
    }];
    
    [self.phoneText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.line.mas_right).offset(18);
        make.right.mas_equalTo(self.bgView).offset(-28);
        make.centerY.mas_equalTo(self.areaButton);
        make.height.mas_equalTo(44);
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView).offset(-28);
        make.top.mas_equalTo(self.phoneText.mas_bottom).offset(18);
        make.size.mas_equalTo(CGSizeMake(88, 44));
    }];
    
    [self.codeText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).offset(28);
        make.right.mas_equalTo(self.sendButton.mas_left).offset(-8);
        make.centerY.mas_equalTo(self.sendButton);
        make.height.mas_equalTo(44);
    }];
    
    [self.phoneLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.areaButton);
        make.right.mas_equalTo(self.phoneText);
        make.top.mas_equalTo(self.areaButton.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self.codeLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.codeText);
        make.right.mas_equalTo(self.sendButton);
        make.top.mas_equalTo(self.sendButton.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    
    [self.handinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).offset(28);
        make.right.mas_equalTo(self.bgView).offset(-28);
        make.top.mas_equalTo(self.codeLine.mas_bottom).offset(35);
        make.height.mas_equalTo(46);
    }];
}

@end
