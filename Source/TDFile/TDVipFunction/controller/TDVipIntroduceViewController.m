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

#import "TDVipAlertView.h"

@interface TDVipIntroduceViewController () <WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate,LoadStateViewReloadSupport>

@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) UIButton *shareButton;

@property (nonatomic,strong) LoadStateViewController *loadController;

@property (nonatomic,strong) TDVipAlertView *alertView;

@end

@implementation TDVipIntroduceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [Strings elitemba];
    [self setViewConstraint];
    
    self.loadController = [[LoadStateViewController alloc] init];
    [self.loadController setupInControllerWithController:self contentView:self.webView];
}

#pragma mark - WKUIDelegate
////在JS端调用alert函数时，会触发此代理方法。JS端调用alert时所传的数据可以通过message拿到。在原生得到结果后，需要回调JS，是通过completionHandler回调。
//- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
//    NSLog(@"在js中调用alert函数时，会调用该方法。 %@",message);
//    completionHandler();
//}
////JS端调用confirm函数时，会触发此方法，通过message可以拿到JS端所传的数据，在iOS端显示原生alert得到YES/NO后，通过completionHandler回调给JS端
//- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
//    NSLog(@"在js中调用confirm函数时，会调用该方法 %@",message);
//    completionHandler(YES);
//}
////JS端调用prompt函数时，会触发此方法,要求输入一段文本,在原生输入得到文本内容后，通过completionHandler回调给JS
//- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
//    NSLog(@"在js中调用prompt函数时，会调用该方法 %@ -- %@",prompt,defaultText);
//    completionHandler(defaultText);
//}

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

//在收到响应开始加载后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(nonnull WKNavigationResponse *)navigationResponse decisionHandler:(nonnull void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    NSString *url = navigationResponse.response.URL.absoluteString;
     NSLog(@"响应链接 --->> %@",url);
    decisionHandler(WKNavigationResponsePolicyAllow);
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
    [UIView animateWithDuration:0.3 animations:^{
        self.shareButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.shareButton.hidden = YES;
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [UIView animateWithDuration:0.3 animations:^{
        self.shareButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.shareButton.hidden = NO;
    }];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight)];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.scrollView.delegate = self;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.webView.scrollView setBounces:NO];
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/vip?device=ios",ELITEU_URL]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
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
    [self.navigationController pushViewController:packageVC animated:YES];
}

- (void)gotoFindCourse { //发现课程
    [[OEXRouter sharedRouter] showCourseCatalogFromController:self bottomBar:nil searchQuery:nil];
}

@end
