//
//  TDVipIntroduceViewController.m
//  edX
//
//  Created by Elite Edu on 2018/12/3.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDVipIntroduceViewController.h"
#import "TDVipPackageViewController.h"
#import <WebKit/WebKit.h>
#import "OEXRouter.h"
#import "edX-Swift.h"
#import "OEXConfig.h"

@interface TDVipIntroduceViewController () <WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate,LoadStateViewReloadSupport>

@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) UIButton *shareButton;

@property (nonatomic,strong) LoadStateViewController *loadController;

@end

@implementation TDVipIntroduceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [Strings membership];
    [self setViewConstraint];
    
    self.loadController = [[LoadStateViewController alloc] init];
    [self.loadController setupInControllerWithController:self contentView:self.webView];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"页面开始加载");
    [self.loadController loadViewStateWithStatus:0 error:nil];
    self.shareButton.hidden = YES;
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"内容开始返回");
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"内容加载完毕");
    [self.loadController loadViewStateWithStatus:1 error:nil];
    self.shareButton.hidden = NO;
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"内容加载失败");
    [self.loadController loadViewStateWithStatus:2 error:error];
    self.shareButton.hidden = YES;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"内容加载错误");
    [self.loadController loadViewStateWithStatus:2 error:error];
    self.shareButton.hidden = YES;
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"当webView的web内容进程被终止时调用。(iOS 9.0之后)");
    [self.webView reload];
}

//在请求开始加载之前调用，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSString *url = navigationAction.request.URL.absoluteString;
    NSLog(@"跳转链接 --->> %@",url);
    if ([url hasPrefix:@"eliteu://gotoFindCource"]) { //发现课程
        
        [self gotoFindCourse];
        
        if (decisionHandler) {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }
    else if ([url hasPrefix:@"eliteu://gotoVipPackage"]) { //VIP
        
        [self gotoVipPackgeVC:[self getVipID:url]];
        
        if (decisionHandler) {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }
    else {
        if (decisionHandler) {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
}

- (NSString *)getVipID:(NSString *)url {
    NSRange range = [url rangeOfString:@"="];
    return [url substringFromIndex:range.location+1];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.shareButton.hidden = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.shareButton.hidden = NO;
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    self.shareButton.hidden = NO;
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

#pragma mark - UI
- (void)setViewConstraint {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight)];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.scrollView.delegate = self;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    [self.webView.scrollView setBounces:NO];
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    self.shareButton = [[UIButton alloc] init];
    self.shareButton.layer.masksToBounds = YES;
    self.shareButton.layer.cornerRadius = 24.0;
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"share_image"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(self.view).offset(-18);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    
    [self loadRequestWebView];
}

- (void)loadRequestWebView {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ELITEU_URL,self.urlStr]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - LoadStateViewReloadSupport
- (void)loadStateViewReload {
    [self loadRequestWebView];
}

#pragma mark - Action
- (void)shareButtonAction:(UIButton *)sender { //分享
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/vip",ELITEU_URL]];
    NSArray *itemArray = @[[Strings studyMbaEliteu],url];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:itemArray applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
    activityController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (completed) {//成功
            NSLog(@"---->> 分享成功");
        }
        else {
            NSLog(@"---->> 分享失败");
        }
    };
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)gotoVipPackgeVC:(NSString *)vipID {//vip列表
    TDVipPackageViewController *packageVC = [[TDVipPackageViewController alloc] init];
    packageVC.vipID = vipID;
    packageVC.username = self.username;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:packageVC animated:YES];
}

- (void)gotoFindCourse { //发现课程
    [self.navigationController popViewControllerAnimated:NO];
    if (self.gotoCategoryHandle) {
        self.gotoCategoryHandle();
    }
}

@end
