//
//  TDSegmentedPageViewController.h
//  HGPersonalCenterExtend
//
//  Created by Arch on 2019/1/3.
//  Copyright © 2019 mint_bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDCategoryView.h"

@protocol TDSegmentedPageViewControllerDelegate <NSObject>
@optional
- (void)segmentedPageViewControllerWillBeginDragging;
- (void)segmentedPageViewControllerDidEndDragging;
- (void)segmentedPageViewControllerDidEndDeceleratingWithPageIndex:(NSInteger)index;
@end

@interface TDSegmentedPageViewController : UIViewController

@property (nonatomic, strong, readonly) TDCategoryView *categoryView;
@property (nonatomic, copy) NSArray<UIViewController *> *pageViewControllers;
@property (nonatomic, strong, readonly) UIViewController *currentPageViewController;
@property (nonatomic, readonly) NSInteger selectedIndex;
@property (nonatomic, weak) id<TDSegmentedPageViewControllerDelegate> delegate;

@end

