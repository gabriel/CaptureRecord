//
//  CRUtils.m
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/29/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//
//  Licensed under the Cocoa Controls commercial license agreement, v1, included
//  with the original package and can also be found at:
//  <http://CocoaControls.com/licenses/v1/license.pdf>.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "CRUtils.h"
#include <CommonCrypto/CommonHMAC.h>
#include <sys/utsname.h>

#define IN
#define OUT
#define INOUT
size_t cr_ybase64_encode(IN const void * from, IN const size_t from_len, OUT void * to, IN const size_t to_len);

void CRDispatch(dispatch_block_t block) {
  dispatch_async(dispatch_get_current_queue(), block);
}

void CRDispatchAfter(NSTimeInterval seconds, dispatch_block_t block) {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_current_queue(), block);
}


@implementation CRUtils

// Based on code by powidl
// http://www.codecollector.net/view/4900E3BB-032E-4E89-81C7-34097E98C286
+ (NSString *)cr_rot13:(NSString *)str {
  const char *cString = [str cStringUsingEncoding:NSASCIIStringEncoding];
  NSInteger stringLength = [str length];
  char newString[stringLength + 1];
  
  NSInteger i;
  for (i = 0; i < stringLength; i++) {
    unsigned char character = cString[i];
    // Check if character is A - Z
    if(0x40 < character && character < 0x5B)
      newString[i] = (((character - 0x41) + 0x0D) % 0x1A) + 0x41;
    // Check if character is a - z
    else if( 0x60 < character && character < 0x7B )
      newString[i] = (((character - 0x61) + 0x0D) % 0x1A) + 0x61;
    else
      newString[i] = character;
  }
  
  newString[i] = '\0';
  
  return [NSString stringWithCString:newString encoding:NSASCIIStringEncoding];
}

+ (BOOL)cr_exist:(NSString *)filePath {
  return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (NSString *)cr_temporaryFile:(NSString *)appendPath deleteIfExists:(BOOL)deleteIfExists error:(NSError **)error {
  NSString *tmpFile = NSTemporaryDirectory();
	if (appendPath) tmpFile = [tmpFile stringByAppendingPathComponent:appendPath];
  if (deleteIfExists && [self cr_exist:tmpFile]) {
    [[NSFileManager defaultManager] removeItemAtPath:tmpFile error:error];
  }
  return tmpFile;
}

+ (NSError *)cr_errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)localizedDescription {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:localizedDescription forKey:NSLocalizedDescriptionKey];
	return [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

+ (NSString *)machine {
  struct utsname u;
  if (uname(&u) >= 0) return [NSString stringWithUTF8String:u.machine];
  return nil;
}

@end
