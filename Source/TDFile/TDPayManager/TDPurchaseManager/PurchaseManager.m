//
//  PurchaseManager.m
//  edX
//
//  Created by Elite Edu on 16/11/22.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "PurchaseManager.h"
#import <AFNetworking.h>
#import "OEXAuthentication.h"
#import "NSDictionary+OEXEncoding.h"
#import "edX-Swift.h"

//在内购项目中创的商品单号
#define ProductID_IAP_198 @"cn.elitemba.iOS.Purchase1"
#define ProductID_IAP_488 @"cn.elitemba.iOS.Purchase2"
#define ProductID_IAP_898 @"cn.elitemba.iOS.Purchase3"
#define ProductID_IAP_1198 @"cn.elitemba.iOS.Purchase4"

@implementation PurchaseManager

- (instancetype)init {
    if (self = [super init]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)showPurchaseComplete:(void(^)(BOOL approveSucess))completion {//App是否审核通过
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"iOS" forKey:@"platform"];
    NSString *url = [NSString stringWithFormat:@"%@%@",ELITEU_URL,APP_APPROVE_STATUS_URL];
    
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        if ([[dict allKeys] containsObject:@"last_version"]) {
            NSDictionary *versionDic = dict[@"last_version"];
            
            NSString *infoFile = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
            NSMutableDictionary *infodic = [[NSMutableDictionary alloc] initWithContentsOfFile:infoFile];
            NSString *appVersion = infodic[@"CFBundleShortVersionString"];//app版本号
            NSString *serviceVersion = versionDic[@"last_version"];//后台返回的版本号
            BOOL approveSucess = [versionDic[@"is_audited"] boolValue];//是否已审核通过
            
            if ([serviceVersion compare:appVersion options:NSNumericSearch] == NSOrderedDescending) {//降序 : 后台的版本 > app的版本
                approveSucess = YES;//老版本：使用支付宝和微信
                // NSLog(@"后台版本 > app版本 --> service:%@ --- app:%@",serviceVersion,appVersion);
            }
            else {
                //版本相同的时候，就是用后台是否审核通过的返回值
                // NSLog(@"app版本 >= 后台版本:service:%@ ->app:%@ = %d",serviceVersion,appVersion,hideShowPurchase);
            }
            completion(approveSucess);
        }
        else {
            completion(YES);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(YES);
        NSLog(@"版本管理： error--%@",error);
    }];
}

- (void)verificationAction:(PurchaseModel *)purchaseModel completion:(void(^)(BOOL isSuccess))completion {
    
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
    NSString *file = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary *fileDic = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
    NSString *version = [fileDic objectForKey:@"CFBundleShortVersionString"];
    [newDic setValue:version forKey:@"version"];//版本号
    [newDic setValue:[[UIDevice currentDevice] systemVersion] forKey:@"os_version"];//系统版本
    
    NSMutableDictionary *dic = [purchaseModel autoParameteDictionary];
    [dic addEntriesFromDictionary:newDic];//向字典中添加字典对象
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",ELITEU_URL,APP_PURCHASE_VERIFY_URL];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *body = [dic oex_stringByUsingFormEncoding];
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:[sessionConfig defaultHTTPHeaders]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString* authValue = [OEXAuthentication authHeaderForApiAccess];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
        if(httpResp.statusCode == 200) {
            NSError* error;
            NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"内购验证 ----->> %@",dictionary);
            if ([dictionary[@"status"] intValue] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     completion(YES);
                });
                NSLog(@"-----验证成功---------");
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO);
                });
                NSLog(@"-----验证失败---------");
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
            NSLog(@"-----验证失败---------");
        }
    }]resume];
}

- (void)reqToUpMoneyFromApple:(int)type {//发起内购
    
    buyType = type;
    if ([SKPaymentQueue canMakePayments]) {
        [self RequestProductData];
        NSLog(@"允许程序内付费购买");
    }
    else {
        NSLog(@"不允许程序内付费购买");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"系统提示" message:@"您的手机没有打开程序内付费购买" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:action];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)RequestProductData {
    NSLog(@"---------请求对应的产品信息------------");
    
    NSArray *product = nil;
    switch (buyType) {
        case IAP_198:
            product = [[NSArray alloc] initWithObjects:ProductID_IAP_198,nil];
            break;
        case IAP_488:
            product = [[NSArray alloc] initWithObjects:ProductID_IAP_488,nil];
            break;
        case IAP_898:
            product = [[NSArray alloc] initWithObjects:ProductID_IAP_898,nil];
            break;
        case IAP_1198:
            product = [[NSArray alloc] initWithObjects:ProductID_IAP_1198,nil];
            break;
        default:
            break;
    }
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate = self;
    [request start];
}

#pragma mark - SKProductsRequestDelegate
//收到的产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"-----------收到产品反馈信息--------------");
    NSArray *myProduct = response.products;
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %d", (int)[myProduct count]);
    // populate UI
    
    NSString *identifier;
    switch (buyType) {
        case IAP_198:
            identifier = ProductID_IAP_198;
            break;
        case IAP_488:
            identifier = ProductID_IAP_488;
            break;
        case IAP_898:
            identifier = ProductID_IAP_898;
            break;
        case IAP_1198:
            identifier = ProductID_IAP_1198;
            break;
        default:
            identifier = ProductID_IAP_198;
            break;
    }
    SKProduct *pro = nil;
    for(SKProduct *product in myProduct){
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
        
        if ([product.productIdentifier isEqualToString:identifier]) {
            pro = product;
        }
    }
    if (pro == nil) {
        NSLog(@"------ 空 -------");
        return;
    }
    SKPayment *payment = [SKPayment paymentWithProduct:pro];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    NSLog(@"---------发送购买请求------------");
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"-------弹出错误信息----------");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"系统提示" message:@"购买失败，请重新购买" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"----------反馈信息结束--------------");
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {//交易结果
    NSLog(@"-----updatedTransactions--------");
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:{//交易完成
                
                NSURL *receiveUrl = [[NSBundle mainBundle] appStoreReceiptURL];
                NSData *receiveData = [NSData dataWithContentsOfURL:receiveUrl];
                NSString *receiveStr = [receiveData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
                if (receiveStr.length == 0) {
                    return;
                }
                [self.delegate updatedTAppApproveransactions:SKPaymentTransactionStatePurchased receiveStr:receiveStr];
                [self completeTransaction:transaction];
                NSLog(@"-----交易完成 --------");
                
            } break;
            case SKPaymentTransactionStateFailed: {//交易失败
                [self failedTransaction:transaction];
                NSLog(@"-----交易失败 --------");
                [self.delegate updatedTAppApproveransactions:SKPaymentTransactionStateFailed receiveStr:@"购买失败，请重新尝试购买"];
            }
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                NSLog(@"-----已经购买过该商品 --------");
                
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"-----商品添加进列表 --------");
                
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"-------restoreCompletedTransactionsFailedWithError----");
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"-----completeTransaction--------");
    
    // Your application should implement these two methods.
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {
        
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
    }
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

//记录交易
- (void)recordTransaction:(NSString *)product {
    NSLog(@"-----记录交易--------");
}

//处理下载内容
- (void)provideContent:(NSString *)product {
    NSLog(@"-----下载--------");
}

//处理失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
        
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@" 交易恢复处理");
}

-(void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
}

#pragma mark - 才去服务器向App Store验证方式，不用本地验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt" //正式环境验证
/**
 *  验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 */
//- (void)verifyPurchaseWithPaymentTransaction {
//    //从沙盒中获取交易凭证并且拼接成请求体数据
//    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
//    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
//
//    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
//
//    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];//拼接请求数据
//    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
//
//
//    //创建请求到苹果官方进行购买验证
//    NSURL *url=[NSURL URLWithString:SANDBOX];
//    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
//    requestM.HTTPBody=bodyData;
//    requestM.HTTPMethod=@"POST";
//    //创建连接并发送同步请求
//    NSError *error=nil;
//    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
//    if (error) {
//        NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
//        return;
//    }
//    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
//    NSLog(@"%@",dic);
//
//    if([dic[@"status"] intValue]==0){
//        NSLog(@"购买成功！");
//        NSDictionary *dicReceipt= dic[@"receipt"];
//        NSDictionary *dicInApp=[dicReceipt[@"in_app"] firstObject];
//        NSString *productIdentifier= dicInApp[@"product_id"];//读取产品标识
//
//        //如果是消耗品则记录购买数量，非消耗品则记录是否购买过
//        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
//        if ([productIdentifier isEqualToString:@"123"]) {
//            NSInteger purchasedCount=[defaults integerForKey:productIdentifier];//已购买数量
//            [defaults setInteger:(purchasedCount+1) forKey:productIdentifier];
//        }
//        else{
//            [defaults setBool:YES forKey:productIdentifier];
//        }
//        //        [SVProgressHUD showSuccessWithStatus:@"购买成功"];
//        //在此处对购买记录进行存储，可以存储到开发商的服务器端
//
//    }
//    else {
//        [[UIApplication sharedApplication].keyWindow.rootViewController.view makeToast:@"购买失败，未通过验证！" duration:1.08 position:CSToastPositionCenter];
//        NSLog(@"购买失败，未通过验证！");
//    }
//}

@end
