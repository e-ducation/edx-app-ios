//
//  TDVipPackageCell.m
//  edX
//
//  Created by Elite Edu on 2018/11/30.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDVipPackageCell.h"

@interface TDVipPackageCell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIImageView *cornerImage;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *originLabel;
@property (nonatomic,strong) UILabel *priceLabel;

@end

@implementation TDVipPackageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    
    self.priceLabel.textColor = [UIColor colorWithHexString:isSelect ? @"#fa7f2b" : @"#4788c7"];
    self.bgButton.selected = isSelect;
}

- (void)setModel:(TDVipPackageModel *)model {
    _model = model;
    
    self.nameLabel.text = model.name;
    self.originLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:model.suggested_price attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlinePatternSolid | NSUnderlineStyleSingle)}];
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:model.price];
    [attStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:14] range:NSMakeRange(attStr.length - 2, 2)];
    self.priceLabel.attributedText = attStr;
    
    self.cornerImage.hidden = ![model.is_recommended boolValue];
}

#pragma mark - UI
- (void)configView {
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    [self addSubview:self.bgView];
    
    self.bgButton = [[UIButton alloc] init];
    self.bgButton.showsTouchWhenHighlighted = YES;
    [self.bgButton setBackgroundImage:[UIImage imageNamed:@"vip_no_select"] forState:UIControlStateNormal];
    [self.bgButton setBackgroundImage:[UIImage imageNamed:@"vip_select"] forState:UIControlStateSelected];
    [self.bgView addSubview:self.bgButton];
    
    NSString *imageStr = [[NSLocale currentLocale].languageCode isEqualToString:@"en"] ? @"vip_recomend_en" : @"vip_recomend";
    self.cornerImage = [[UIImageView alloc] init];
    self.cornerImage.image = [UIImage imageNamed:imageStr];
    [self.bgView addSubview:self.cornerImage];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
    self.nameLabel.textColor = [UIColor colorWithHexString:@"#2e313c"];
    [self.bgView addSubview:self.nameLabel];
    
    self.originLabel = [[UILabel alloc] init];
    self.originLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    self.originLabel.textColor = [UIColor colorWithHexString:@"#656d78"];
    [self.bgView addSubview:self.originLabel];
    
    self.priceLabel = [[UILabel alloc] init];
    self.priceLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:22];
    self.priceLabel.textColor = [UIColor colorWithHexString:@"#4788c7"];//#fa7f2b
    [self.bgView addSubview:self.priceLabel];
    
    self.nameLabel.text = @"一个月会员";
    
    self.originLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@"0.00" attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle)}];
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"￥0.00"];
    [attStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFangSC-Regular" size:14] range:NSMakeRange(attStr.length - 2, 2)];
    self.priceLabel.attributedText = attStr;
    
    self.cornerImage.hidden = YES;
    
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.top.bottom.mas_equalTo(self.bgView);
    }];
    
    [self.cornerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgButton.mas_top).offset(2);
        make.left.mas_equalTo(self.bgButton.mas_left).offset(4);
        make.size.mas_equalTo(CGSizeMake(33, 33));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgButton.mas_left).offset(20);
        make.bottom.mas_equalTo(self.bgButton.mas_centerY);
    }];
    
    [self.originLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.top.mas_equalTo(self.bgButton.mas_centerY).offset(8);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgButton.mas_right).offset(-20);
        make.centerY.mas_equalTo(self.bgButton.mas_centerY);
    }];
}

@end
