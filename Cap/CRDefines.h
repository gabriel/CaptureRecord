//
//  CRDefines.h
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#define CRSetError(__ERROR__, __ERROR_CODE__, __DESC__, ...) do { \
NSString *message = [NSString stringWithFormat:__DESC__, ##__VA_ARGS__]; \
NSLog(@"%@", message); \
if (__ERROR__) *__ERROR__ = [NSError errorWithDomain:@"Cap" code:__ERROR_CODE__ \
userInfo:[NSDictionary dictionaryWithObjectsAndKeys:message, NSLocalizedDescriptionKey,  \
nil]]; \
} while (0)

#if DEBUG
#define CRDebug(...) NSLog(__VA_ARGS__)
#define CRWarn(...) NSLog(__VA_ARGS__)
#else
#define CRDebug(...) do { } while(0)
#define CRWarn(...) do { } while(0)
#endif

