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

@interface TDVipIntroduceViewController () <WKUIDelegate,WKNavigationDelegate>

@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) UIButton *payButton;
@property (nonatomic,strong) UIActivityIndicatorView *activityView;

@end

@implementation TDVipIntroduceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"商学院";
    [self setViewConstraint];
}

#pragma mark - WKUIDelegate
//- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
//
//}

//在JS端调用alert函数时，会触发此代理方法。JS端调用alert时所传的数据可以通过message拿到。在原生得到结果后，需要回调JS，是通过completionHandler回调。
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"在js中调用alert函数时，会调用该方法。 %@",message);
    completionHandler();
}
//JS端调用confirm函数时，会触发此方法，通过message可以拿到JS端所传的数据，在iOS端显示原生alert得到YES/NO后，通过completionHandler回调给JS端
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"在js中调用confirm函数时，会调用该方法 %@",message);
    completionHandler(YES);
}
//JS端调用prompt函数时，会触发此方法,要求输入一段文本,在原生输入得到文本内容后，通过completionHandler回调给JS
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    NSLog(@"在js中调用prompt函数时，会调用该方法 %@ -- %@",prompt,defaultText);
    completionHandler(defaultText);
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"页面开始加载");
    [self.activityView startAnimating];
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"内容开始返回");
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"内容加载完毕");
    [self.activityView stopAnimating];
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"内容加载失败");
    [self.activityView stopAnimating];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"内容加载错误");
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"收到服务器重定向请求后调用");
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
        [self.activityView stopAnimating];
    }
    else if ([url hasPrefix:@"eliteu://gotoVipPackage"]) { //VIP
        
        [self gotoVipPackgeVC];
        
        if (decisionHandler) {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
        [self.activityView stopAnimating];
    }
    else {
        if (decisionHandler) {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.payButton = [[UIButton alloc] init];
    self.payButton.backgroundColor = [UIColor colorWithHexString:@"#fc9753"];
    [self.payButton setTitle:@"购买VIP" forState:UIControlStateNormal];
    [self.payButton addTarget:self action:@selector(payButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.payButton];
    
    [self.payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(48);
    }];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight)];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://crews.ngrok.elitemc.cn:8000/vip?device=ios"]]];
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.payButton.mas_top);
    }];
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.webView addSubview:self.activityView];
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.webView.mas_centerX);
        make.centerY.mas_equalTo(self.webView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(33, 33));
    }];
}

- (void)payButtonAction:(UIButton *)sender {
    [self gotoVipPackgeVC];
}

- (void)gotoVipPackgeVC {
    TDVipPackageViewController *packageVC = [[TDVipPackageViewController alloc] init];
    [self.navigationController pushViewController:packageVC animated:YES];
}

- (void)gotoFindCourse { 
    [[OEXRouter sharedRouter] showCourseCatalogFromController:self bottomBar:nil searchQuery:nil];
}

@end
