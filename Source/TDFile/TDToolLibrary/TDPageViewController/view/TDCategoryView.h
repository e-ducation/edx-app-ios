//
//  TDCategoryView.h
//  HGPersonalCenterExtend
//
//  Created by Arch on 2018/8/20.
//  Copyright © 2018年 mint_bin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDCategoryViewCollectionViewCell : UICollectionViewCell
@property (nonatomic, readonly, strong) UILabel *titleLabel;
@end;

@interface TDCategoryView : UIView

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) UIView *underline;
@property (nonatomic, strong, readonly) UIView *separator;

@property (nonatomic, strong) UIFont *titleNomalFont; //普通字体大小
@property (nonatomic, strong) UIFont *titleSelectedFont;//选中的字体大小
@property (nonatomic, strong) UIColor *titleNormalColor;//普通字体颜色
@property (nonatomic, strong) UIColor *titleSelectedColor;//选中的字体颜色
@property (nonatomic) NSInteger originalIndex;//初始选中
@property (nonatomic, readonly) NSInteger selectedIndex; //选中

@property (nonatomic, copy) NSArray<NSString *> *titles;//标题

@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat cellSpacing;
@property (nonatomic) CGFloat leftAndRightMargin; // default = cellSpacing

@property (nonatomic, copy) void (^selectedItemHelper)(NSUInteger index);

- (void)changeItemWithTargetIndex:(NSUInteger)targetIndex;

@end
