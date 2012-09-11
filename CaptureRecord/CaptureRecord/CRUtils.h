//
//  CRUtils.h
//  CaptureRecord
//
//  Created by Gabriel Handford on 8/29/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

@interface CRUtils : NSObject
+ (NSString *)cr_rot13:(NSString *)str;
+ (BOOL)cr_exist:(NSString *)filePath;
+ (NSString *)cr_temporaryFile:(NSString *)appendPath deleteIfExists:(BOOL)deleteIfExists error:(NSError **)error;
+ (NSError *)cr_errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)localizedDescription;
+ (NSString *)cr_HMACSHA1WithMessage:(NSString *)message secret:(NSString *)secret;
@end
