//
//  CRUtils.m
//  CaptureRecord
//
//  Created by Gabriel Handford on 8/29/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import "CRUtils.h"
#include <CommonCrypto/CommonHMAC.h>

#define IN
#define OUT
#define INOUT
size_t cr_ybase64_encode(IN const void * from, IN const size_t from_len, OUT void * to, IN const size_t to_len);


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

+ (NSString *)cr_base64EncodeWithBytes:(const void *)bytes length:(NSUInteger)length {
  size_t len = cr_ybase64_encode(bytes, length, NULL, 0);
  void * stringData = malloc(len);
  len = cr_ybase64_encode(bytes, length, stringData, len);
  NSString * s = [NSString stringWithUTF8String:stringData];
  free(stringData);
  return s;
}

+ (NSString *)cr_HMACSHA1WithMessage:(NSString *)message secret:(NSString *)secret {
  NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
  NSData *clearTextData = [message dataUsingEncoding:NSUTF8StringEncoding];
  
  unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
  CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], cHMAC);
  
  return [self cr_base64EncodeWithBytes:cHMAC length:sizeof(cHMAC)];
  
  // From old hmac.h and sha1.h implementation
  /*
   unsigned char digest[20];
   HMAC_SHA1(digest, (unsigned char *)[clearTextData bytes], (unsigned int)[clearTextData length], (unsigned char *)[secretData bytes], (unsigned int)[secretData length]);
   
   NSData *data = [(id<GHBase64Encoder>)base64Encoder encodeBytes:digest length:20];
   return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
   */
}

@end

#pragma mark Base64

//returned len includes \0
size_t cr_ybase64_encode( IN const void * from,
                      IN const size_t from_len,
                      OUT void * to,
                      IN const size_t to_len)
{
  static const char base64_encoding_map[65] =
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  if (NULL == from || 0 == from_len) {
    return 0;
  }
  
  // I will need some paramerters, so I don't use the '(from_len + 2) / 3 * 4' to calculate len
  const size_t chunk_len = from_len / 3;
  const size_t aligned_len = chunk_len * 3;
  size_t left = from_len - aligned_len;
  const size_t left_char = left?(left + 1):0;
  const size_t padding = left?(3 - left):0;
  
  const size_t need_len = left_char + chunk_len * 4 + padding + 1 /* \0 null end */ ;
  
  if (NULL == to) {
    return need_len;
  }
  
  // if need partialy encoded string, can use the callback
  if (to_len < need_len) {
    return 0;
  }
  
  unsigned char b1, b2, b3;
  unsigned char c1, c2 ,c3, c4;
  unsigned int m;
  unsigned int bits;
  const unsigned char * p_from = (const unsigned char *)from;
  unsigned char * p_to = (unsigned char *)to;
  size_t i = 0, j = 0;
  
  // use aligned bytes to omit most of conditional statements, means less CMPs & JMPs
  for (; i < aligned_len ;) {
    
    b1 = *(p_from + i);
    b2 = *(p_from + i + 1);
    b3 = *(p_from + i + 2); //slightly faster than the commented, for 14~15MB data, 10ms faster
    //        b1 = *(p_from);p_from ++;
    //        b2 = *(p_from);p_from ++;
    //        b3 = *(p_from);p_from ++;
    i += 3;
    
    // combined a whole 24-bit chunk
    bits = (b1 << 16) | (b2 << 8) | (b3);
    m = (bits & 0xfc0000) >> 18;
    //        m = (b1 & 0xfc) >> 2;
    c1 = base64_encoding_map[m];
    
    m = (bits & 0x3f000) >> 12;
    //        m = ((b1 & 0x3) << 4 ) | ((b2 & 0xf0) >> 4);
    c2 = base64_encoding_map[m];
    
    m = (bits & 0xfc0) >> 6;
    //        m = ((b2 & 0xf) << 2) | ((b3 & 0xc0) >> 6);
    c3 = base64_encoding_map[m];
    
    m = (bits & 0x3f);
    //        m = b3 & 0x3f;
    c4 = base64_encoding_map[m];
    
    if (p_to) {
      *(p_to + j) = c1;
      *(p_to + j + 1) = c2;
      *(p_to + j + 2) = c3;
      *(p_to + j + 3) = c4;
      //            *(p_to) = c1; p_to ++;
      //            *(p_to) = c2; p_to ++;
      //            *(p_to) = c3; p_to ++;
      //            *(p_to) = c4; p_to ++;
      
    }
    j += 4;
  }
  
  //handle the last things
  switch (padding) {
    case 0:
      break;
    case 2:
    {
      b1 = *(p_from + i);
      m = b1 >> 2;
      c1 = base64_encoding_map[m];
      
      m = (b1 & 0x3) << 4;
      c2 = base64_encoding_map[m];
      
      if (p_to) {
        *(p_to + j) = c1;
        *(p_to + j + 1) = c2;
        *(p_to + j + 2) = '=';
        *(p_to + j + 3) = '=';
        //                *(p_to) = c1; p_to ++;
        //                *(p_to) = c2; p_to ++;
        //                *(p_to) = '='; p_to ++;
        //                *(p_to) = '='; p_to ++;
      }
      j += 4;
    }
      break;
    case 1:
    {
      b1 = *(p_from + i);
      b2 = *(p_from + i + 1);
      //            b1 = *p_from; p_from ++;
      //            b2 = *p_from; p_from ++;
      
      m = b1 >> 2;
      c1 = base64_encoding_map[m];
      
      m = ((b1 & 0x3) << 4) | (b2 >> 4);
      c2 = base64_encoding_map[m];
      
      m = (b2 & 0xf) << 2;
      c3 = base64_encoding_map[m];
      
      if (p_to) {
        *(p_to + j) = c1;
        *(p_to + j + 1) = c2;
        *(p_to + j + 2) = c3;
        *(p_to + j + 3) = '=';
        //                *(p_to) = c1; p_to ++;
        //                *(p_to) = c2; p_to ++;
        //                *(p_to) = c3; p_to ++;
        //                *(p_to) = '='; p_to ++;
      }
      j += 4;
    }
      break;
  }
  
  *(p_to + j) = '\0';
  //    *(p_to) = '\0';
  assert(need_len == j + 1);
  
  return need_len;
}
