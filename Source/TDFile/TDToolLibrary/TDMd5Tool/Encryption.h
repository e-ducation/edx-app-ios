//
//  Encryption.h
//  edX
//
//  Created by Elite Edu on 16/9/20.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encryption : NSObject

+ (NSString *)md5EncryptWithString:(NSString *)string;
+ (NSString *)md5:(NSString *)string;
+ (NSString *)newMd5:(NSString *)string;
+ (NSString *)MD5ForUpper32Bate:(NSString *)str;

@end
