//
//  TDSegmentedPageViewController.m
//  HGPersonalCenterExtend
//
//  Created by Arch on 2019/1/3.
//  Copyright © 2019 mint_bin. All rights reserved.
//

#import "TDSegmentedPageViewController.h"
#import "Masonry.h"

@interface TDSegmentedPageViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) TDCategoryView *categoryView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic) NSInteger selectedIndex;
@end

@implementation TDSegmentedPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedIndex = self.categoryView.originalIndex;
    
    [self.view addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(self->_categoryView.height);
    }];
    
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.categoryView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
    
    __weak typeof(self) weakSelf = self;
    weakSelf.categoryView.selectedItemHelper = ^(NSUInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setUpChildViewController:index];
        [strongSelf.scrollView setContentOffset:CGPointMake(index * TDWidth, 0) animated:NO];
        self.selectedIndex = index;
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setUpChildViewController:self.selectedIndex];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

/* 添加对应的子控制器 */
- (void)setUpChildViewController:(NSInteger)index {
    
    UIViewController *vc = self.pageViewControllers[index];
    if (vc.view.superview) {
        return;
    }
    CGFloat x = index * TDWidth;
    vc.view.frame = CGRectMake(x, 0, TDWidth, self.scrollView.bounds.size.height);
    [self.scrollView addSubview:vc.view];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentedPageViewControllerWillBeginDragging)]) {
        [self.delegate segmentedPageViewControllerWillBeginDragging];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentedPageViewControllerDidEndDragging)]) {
        [self.delegate segmentedPageViewControllerDidEndDragging];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger index = (NSUInteger)(self.scrollView.contentOffset.x / TDWidth);
    [self.categoryView changeItemWithTargetIndex:index];
    self.selectedIndex = index;
    [self setUpChildViewController:index];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentedPageViewControllerDidEndDeceleratingWithPageIndex:)]) {
        [self.delegate segmentedPageViewControllerDidEndDeceleratingWithPageIndex:index];
    }
}

#pragma mark - Getters
- (TDCategoryView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[TDCategoryView alloc] init];
    }
    return _categoryView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.contentSize = CGSizeMake(TDWidth * self.pageViewControllers.count, 0);
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.selectedIndex == 0) {
        return YES;
    }
    return NO;
}

@end
