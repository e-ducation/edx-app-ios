//
//  OssService.h
//  OssIOSDemo
//  Created by jingdan on 17/11/23.
//  Copyright © 2015年 Ali. All rights reserved.
//

#ifndef OssService_h
#define OssService_h

#import <AliyunOSSiOS/OSSService.h>

#import "OSSConstants.h"

typedef NS_ENUM(NSInteger, TDOssFileType) {
    TDOssFileTypeAudio = 2,
    TDOssFileTypeImage,
    TDOssFileTypeVideo
};

//typedef void(^PutOsssHandle)();

@protocol TDOssPutFileDelegate <NSObject>

- (void)putFileToOssSucessDomain:(NSString *)domain fid:(NSString *)fid type:(TDOssFileType)type inturn:(NSInteger)turn total:(NSInteger)total;
- (void)putFileToOssFailed:(NSString *)reason type:(TDOssFileType)type;

@end

@interface OssService : NSObject

@property (nonatomic,assign) TDOssFileType type;
@property (nonatomic,weak) id <TDOssPutFileDelegate> delegate;

- (void)getTokenFromOssStsUrl;//获取token
- (void)asyncPutImage:(NSString *)objectKey localFilePath:(NSString *)filePath inturn:(NSInteger)turn total:(NSInteger)total; //异步推文件
- (void)asyncGetImage:(NSString *)objectKey; //下载文件
- (void)normalRequestCancel;//取消

//- (void)triggerCallback;

- (NSString *)dealDateFormatter:(NSString *)username type:(NSString *)typeStr ;//文件路径拼接
- (NSString *)saveImage:(UIImage *)currentImage withName:(NSString *)imageName;//保存图片到本地路径

@end

#endif /* OssService_h */

