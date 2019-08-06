//
//  OssService.m
//  OssIOSDemo
//
//  Created by jingdan on 17/11/23.
//  Copyright © 2015年 Ali. All rights reserved.
//



#import "OssService.h"
#import <AliyunOSSiOS/OSSService.h>
#import <AFNetworking/AFNetworking.h>
//#import "OSSTestMacros.h"

@interface OssService () {
    
    OSSClient *client;
    OSSPutObjectRequest *putRequest;
    OSSGetObjectRequest *getRequest;
    OSSResumableUploadRequest *resumableRequest; // 简单起见，全局只维护一个断点上传任务
}

@end

@implementation OssService

- (instancetype)init {
    if (self = [super init]) {
//        [self getTokenFromOssStsUrl];
    }
    return self;
}

- (void)getTokenFromOssStsUrl { //通过授权sts接口，拿到token
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:ACCESS_KEY_ID forKey:@"access_key_id"];
    [dict setValue:ACCESS_KEY_SECRET forKey:@"access_key_secret"];
    
    WS(weakSelf);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:STS_AUTH_URL parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        NSDictionary *credentDic = responseDic[@"Credentials"];
        NSString *accessKeyId = credentDic[@"AccessKeyId"];
        NSString *secretKeyId = credentDic[@"AccessKeySecret"];
        NSString *securityToken = credentDic[@"SecurityToken"];
        [weakSelf ossInitClientWithAccessKeyId:accessKeyId secretKeyId:secretKeyId securityToken:securityToken];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [viewController.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"sts鉴权 -- %ld",(long)error.code);
    }];
}

/**
 *   @brief    初始化获取OSSClient
 */
- (void)ossInitClientWithAccessKeyId:(NSString *)accessKeyId secretKeyId:(NSString *)secretKeyId securityToken:(NSString *)securityToken  {
    
    /* 
     主账号方式
     移动终端是一个不受信任的环境，使用主账号AK，SK直接保存在终端用来加签请求，存在极高的风险。建议只在测试时使用明文设置模式，业务应用推荐使用STS鉴权模式。
     STS鉴权模式可通过https://help.aliyun.com/document_detail/31920.html文档了解更多
     */
    //     id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithAccessKeyId:@"Aliyun_AK" secretKeyId:@"Aliyun_SK"]; //过期的方法
    //    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:@"LTAIaW7yT3C1Ls82" secretKey:@"9RvJCyQE4aS1WgSM84CF75jWadjYTj"];
    
    /* 
     sts 鉴权方式
     如果用STS鉴权模式，推荐使用OSSAuthCredentialProvider方式直接访问鉴权应用服务器，token过期后可以自动更新。
     详见：https://help.aliyun.com/document_detail/31920.html
     OSSClient的生命周期和应用程序的生命周期保持一致即可。在应用程序启动时创建一个ossClient，在应用程序结束时销毁即可 
     */
//    id<OSSCredentialProvider> credential = [[OSSAuthCredentialProvider alloc] initWithAuthServerUrl:STS_AUTH_URL];
    
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:accessKeyId secretKeyId:secretKeyId securityToken:securityToken];
    
    client = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential];
}

/**  @brief    上传图片
 *   @param     objectKey    objectKey
 *   @param     filePath     路径
 */
- (void)asyncPutImage:(NSString *)objectKey localFilePath:(NSString *)filePath inturn:(NSInteger)turn total:(NSInteger)total {
    
    NSLog(@"第几个 -- %ld",(long)turn);
    
    if (objectKey.length == 0) {
        [self.delegate putFileToOssFailed:@"文件名不能为空" type:self.type];
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self.delegate putFileToOssFailed:@"文件不存在" type:self.type];
        return;
    }
    
//    if (![[[TDBaseToolModel alloc] init] getNetworkingState]) {
//        [self.delegate putFileToOssFailed:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) type:self.type];
//        return;
//    }
    
    putRequest = [OSSPutObjectRequest new];
    putRequest.bucketName = BUCKET_NAME;
    putRequest.objectKey = objectKey;
    putRequest.uploadingFileURL = [NSURL fileURLWithPath:filePath];
    
    putRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    
    putRequest.callbackParam = @{
                                 @"callbackUrl": callbackAddress,//设置server callback地址
                                 @"callbackBody": @"{\"filePath\":${x:filePath},\"image_sequence\":${x:image_sequence}}" // callbackBody可自定义传入的信息
                                 };
    putRequest.callbackVar = @{
                               @"x:filePath":objectKey,
                               @"x:image_sequence":[NSString stringWithFormat:@"%ld",(long)turn]
                               };
    
    OSSTask *task = [client putObject:putRequest];
    [task continueWithBlock:^id(OSSTask *task) { //实现异步回调
        
        OSSPutObjectResult *result = task.result;
        if (!task.error) { // 查看server callback是否成功
            NSLog(@"Put image success! server callback : %@", result.serverReturnJsonString);
            
            NSData *jsonData = [result.serverReturnJsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            if(err) {
                NSLog(@"json解析失败：%@",err);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate putFileToOssFailed:@"json解析失败" type:self.type];
                });
                
            } else {
                id code = dic[@"code"];
                
                if ([code intValue] == 200) {
                    NSString *fidStr = dic[@"data"][@"fid"];
                    NSString *domainStr = dic[@"data"][@"domain"];
                    NSString *turnStr = dic[@"data"][@"image_sequence"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate putFileToOssSucessDomain:domainStr fid:fidStr type:self.type inturn:[turnStr integerValue] total:total];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate putFileToOssFailed:@"上传失败" type:self.type];
                    });
                }
            }
            
        } else {
            NSLog(@"Put image failed -- %@", task.error);
            
            if (task.error.code == OSSClientErrorCodeTaskCancelled) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate putFileToOssFailed:@"任务取消!" type:self.type];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate putFileToOssFailed:@"上传失败" type:self.type];
                });
            }
        }
        
        putRequest = nil;
        return nil;
    }];
}

- (NSString *)dealDateFormatter:(NSString *)username type:(NSString *)typeStr { // beta/lms/userid/时间戳文件名字 (prod：生产服务器)
    
    NSDate *date = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateStr = [formatter stringFromDate:date];
    int ar4 = arc4random() % 10000;
    NSString *fileName = [NSString stringWithFormat:@"prod/elitemba/%@/%@%d%@",username,dateStr,ar4,typeStr];
    
    return fileName;
}

- (NSString *)saveImage:(UIImage *)currentImage withName:(NSString *)imageName { //保存图片到本地
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    [imageData writeToFile:fullPath atomically:NO];
    return fullPath;
}

- (void)saveVideo:(NSString *)videoPath name:(NSString *)videoName { //将相册的视频保存到本地
    
}

/**
 *   @brief    下载图片
 */
- (void)asyncGetImage:(NSString *)objectKey {
    
    if (objectKey == nil || [objectKey length] == 0) {
        return;
    }
    getRequest = [OSSGetObjectRequest new];
    getRequest.bucketName = BUCKET_NAME;
    getRequest.objectKey = objectKey;
    OSSTask *task = [client getObject:getRequest];
    [task continueWithBlock:^id(OSSTask *task) {
        OSSGetObjectResult *result = task.result;
        if (!task.error) {
            NSLog(@"Get image success!");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self saveAndDisplayImage:result.downloadedData downloadObjectKey:objectKey];
//                [viewController showMessage:@"普通下载" inputMessage:@"Success!"];
            });
        } else {
            NSLog(@"Get image failed, %@", task.error);
            if (task.error.code == OSSClientErrorCodeTaskCancelled) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [viewController showMessage:@"普通下载" inputMessage:@"任务取消!"];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [viewController showMessage:@"普通下载" inputMessage:@"Failed!"];
                });
            }
        }
        getRequest = nil;
        return nil;
    }];
}

- (void)saveAndDisplayImage:(NSData *)objectData downloadObjectKey:(NSString *)objectKey {
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:objectKey];
    [objectData writeToFile:fullPath atomically:NO];
//    UIImage *image = [[UIImage alloc] initWithData:objectData];
//    uploadFilePath = fullPath;
//    [self.ossImageView setImage:image];
    
}

/**
 *   @brief    普通上传/下载取消
 */
- (void)normalRequestCancel {
    if (putRequest) {
        [putRequest cancel];
    }
    if (getRequest) {
        [getRequest cancel];
    }
}

//- (void)triggerCallback {
//    
//    OSSPlainTextAKSKPairCredentialProvider *provider = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:OSS_ACCESSKEY_ID secretKey:OSS_SECRETKEY_ID];
//    OSSClient *pClient = [[OSSClient alloc] initWithEndpoint:OSS_ENDPOINT credentialProvider:provider];
//    OSSCallBackRequest *request = [OSSCallBackRequest new];
//    request.bucketName = OSS_BUCKET_PRIVATE;
//    request.objectName = @"landscape-painting.jpeg";
//    request.callbackParam = @{@"callbackUrl": OSS_CALLBACK_URL,
//                              @"callbackBody": @"test"};
//    request.callbackVar = @{@"var1": @"value1",
//                            @"var2": @"value2"};
//    
//    [[[pClient triggerCallBack:request] continueWithBlock:^id _Nullable(OSSTask *_Nonnull task) {
//        if (task.result) {
//            OSSCallBackResult *result = (OSSCallBackResult *)task.result;
//            NSLog(@"Result: %@", result.serverReturnJsonString);
//        }
//        
//        return nil;
//    }] waitUntilFinished]; //等待这个Task完成，以实现同步等待
//}


@end

