//
//  TDBindPhoneViewController.m
//  edX
//
//  Created by Elite Edu on 2018/12/12.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDBindPhoneViewController.h"
#import "TDBindPhoneView.h"
#import <AFNetworking/AFNetworking.h>

#import "OEXAuthentication.h"
#import "NSDictionary+OEXEncoding.h"
#import "edX-Swift.h"

@interface TDBindPhoneViewController () <UITextFieldDelegate>

@property (nonatomic,strong) TDBindPhoneView *phoneView;

@property (nonatomic,assign) int timeNum;
@property (nonatomic,strong) NSTimer *timer;//定时器

@end

@implementation TDBindPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"";
    [self setViewConstraint];
}

- (void)dealloc {
    [self timerInvalidate];
}

- (void)showLoading:(NSString *)status {
    [SVProgressHUD showWithStatus:status];
    SVProgressHUD.defaultMaskType = SVProgressHUDMaskTypeBlack;
    SVProgressHUD.defaultStyle = SVProgressHUDStyleDark;
}

#pragma mark - request
- (void)sendPhoneCode {
    [self showLoading:[Strings sendVerificateCode]];
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:self.phoneView.phoneText.text forKey:@"phone"];
    
    NSString *body = [dic oex_stringByUsingFormEncoding];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:[sessionConfig defaultHTTPHeaders]];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ELITEU_URL, APP_BINDPHONE_CODE_URL]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[NSString stringWithFormat:@"openedx-language-preference=%@",[NSLocale currentLocale].languageCode] forHTTPHeaderField:@"Cookie"];
    
    NSString* authValue = [OEXAuthentication authHeaderForApiAccess];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
        if(httpResp.statusCode == 204) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self cutDownTime];
                [self.view makeToast:[Strings verificationSent] duration:0.8 position:CSToastPositionCenter];
            });
        }
        else if (httpResp.statusCode == 400) {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *string = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            //            NSLog(@"返回信息 ----->> %@",str);
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self.view makeToast:string duration:0.8 position:CSToastPositionCenter];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self.view makeToast:[Strings verifycodeFailed] duration:0.8 position:CSToastPositionCenter];
            });
        }
    }]resume];
}

- (void)handinBindPhone {
    [self showLoading:[Strings submintingText]];
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:self.phoneView.phoneText.text forKey:@"phone"];
    [dic setValue:self.phoneView.codeText.text forKey:@"code"];
    
    NSString *body = [dic oex_stringByUsingFormEncoding];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:[sessionConfig defaultHTTPHeaders]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ELITEU_URL, APP_BINGPHONE_URL]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString* authValue = [OEXAuthentication authHeaderForApiAccess];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setValue:[NSString stringWithFormat:@"openedx-language-preference=%@",[NSLocale currentLocale].languageCode] forHTTPHeaderField:@"Cookie"];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
        if(httpResp.statusCode == 204) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.bindingPhoneSuccess) {
                    self.bindingPhoneSuccess();
                }
                [SVProgressHUD dismiss];
                [self.view makeToast:[Strings bindSucced] duration:0.8 position:CSToastPositionCenter];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            });
        }
        else if (httpResp.statusCode == 400) {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *string = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            //            NSLog(@"返回信息 ----->> %@",str);
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self.view makeToast:string duration:0.8 position:CSToastPositionCenter];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self.view makeToast:[Strings bindFailed] duration:0.8 position:CSToastPositionCenter];
            });
        }
    }]resume];
}

#pragma mark -- 倒计时
- (void)cutDownTime {
    self.phoneView.sendButton.userInteractionEnabled = NO;
    self.timeNum = 60;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)timeChange {
    self.phoneView.sendButton.userInteractionEnabled = NO;
    self.timeNum -= 1;
    [self.phoneView.sendButton setTitle:[NSString stringWithFormat:@"%ds",self.timeNum] forState:UIControlStateNormal];
    
    if (self.timeNum <= 0) {
        [self timerInvalidate];
        self.phoneView.sendButton.userInteractionEnabled = YES;
        [self.phoneView.sendButton setTitle:[Strings getVerification] forState:UIControlStateNormal];
    }
}

- (void)timerInvalidate {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Action
- (void)sendButtonAction:(UIButton *)sender { //发送验证码
    [self resignResponder];
    
    if ([self judgePhoneNunber]) {
        [self sendPhoneCode];
    }
}

- (void)handinButtonAction:(UIButton *)sender { //提交
    [self resignResponder];
    
    if ([self judgePhoneNunber] && [self judgeCodeNunber]) {
        [self handinBindPhone];
    }
}

- (BOOL)judgeCodeNunber { //验证码是否为空
    NSString *codeStr = self.phoneView.codeText.text;
    if (codeStr.length == 0) {
        return NO;
    }
    if (codeStr.length != 6) {
        [self.view makeToast:[Strings incorrectCode] duration:1.08 position:CSToastPositionCenter];
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL)judgePhoneNunber { //判断手机是否合法
    
    NSString *phoneStr = self.phoneView.phoneText.text;
    if (phoneStr.length == 0) {
        return NO;
    }
    else if (![self isValidateMobile:self.phoneView.phoneText.text]) {
        [self.view makeToast:[Strings wrongMobile] duration:1.08 position:CSToastPositionCenter];
        return NO;
    }
    else {
        return YES;
    }
}

/*
 手机号码的正则表达式
 */
- (BOOL)isValidateMobile:(NSString *)mobile {
    if (mobile.length <= 0) {
        return NO;
    }
    NSString *phoneRegex = @"^((13[0-9])|16[56]|19[89]|(17[0-9])|(14[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";//^开始，|或，$终止，？允许匹配不上，手机号码以13、15、18、14、17开头，八个\d数字字符
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

- (void)resignResponder {
    [self.phoneView.phoneText resignFirstResponder];
    [self.phoneView.codeText resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([textField isEqual:self.phoneView.phoneText]) {
        [self sendButtonUserEnable:[self judgePhoneNunber]];
    }
    else {
        BOOL enable = [self judgeCodeNunber] && [self judgePhoneNunber];
        [self handinButtonUserEnable:enable];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:self.phoneView.codeText]) {
//        NSLog(@"%@ --->> %@",textField.text,string);
        if (range.length == 0) { //增
            if (textField.text.length + string.length == 6) {
                BOOL enable = [self judgePhoneNunber];
                [self handinButtonUserEnable:enable];
            }
            
            if (textField.text.length == 6) {
                return NO;
            }
        }
        else {//==1 删
            [self handinButtonUserEnable:NO];
            return YES;
        }
    }
    else if ([textField isEqual:self.phoneView.phoneText]) {
        NSString *phonstr = textField.text;
        if (range.length == 0) {
            phonstr = [phonstr stringByAppendingString:string];
        }
        else {
            phonstr = [phonstr substringToIndex:range.location];
        }
        BOOL enable = [self isValidateMobile:phonstr];
        [self sendButtonUserEnable:enable];
    }
    return YES;
}

- (void)sendButtonUserEnable:(BOOL)enable {
    self.phoneView.sendButton.userInteractionEnabled = enable;
    [self.phoneView.sendButton setTitle:[Strings getVerification] forState:UIControlStateNormal];
}

- (void)handinButtonUserEnable:(BOOL)enable {
    self.phoneView.handinButton.userInteractionEnabled = enable;
    self.phoneView.handinButton.backgroundColor = [UIColor colorWithHexString:enable ? @"#0692e1" : @"#d3d3d3"];
}

#pragma mark - UI
- (void)setViewConstraint {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.phoneView = [[TDBindPhoneView alloc] init];
    [self.phoneView.sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.phoneView.handinButton addTarget:self action:@selector(handinButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.phoneView.phoneText.delegate = self;
    self.phoneView.codeText.delegate = self;
    [self.view addSubview:self.phoneView];
    
    [self.phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    if (self.phoneStr.length > 0) {
        self.phoneView.bindLabel.text = [NSString stringWithFormat:@"当前绑定的手机号：%@",self.phoneStr];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
