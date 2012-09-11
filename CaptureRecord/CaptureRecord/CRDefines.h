//
//  CRDefines.h
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/13/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#define CRSetError(__ERROR__, __ERROR_CODE__, __DESC__, ...) do { \
NSString *message = [NSString stringWithFormat:__DESC__, ##__VA_ARGS__]; \
NSLog(@"%@", message); \
if (__ERROR__) *__ERROR__ = [NSError errorWithDomain:CRErrorDomain code:__ERROR_CODE__ \
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

/*!
 Error domain.
 */
extern NSString *const CRErrorDomain;

/*!
 Exception.
 */
extern NSString *const CRException;

/*!
 Recording did start notification.
 Notification object is the CRRecorder instance that started.
 */
extern NSString *const CRRecorderDidStartNotification;

/*!
 Recording did stop notification.
 Notification object is the CRRecorder instance that stopped.
 */
extern NSString *const CRRecorderDidStopNotification;

/*!
 Video did change notification.
 Notification object is the CRVideo instance that changed.
 */
extern NSString *const CRVideoDidChangeNotification;

/*!
 UIEvent notification.
 Notification object is the UIEvent instance.
 */
extern NSString *const CRUIEventNotification;


typedef enum : NSInteger {
  CRErrorCodeInvalidVideo = -100,
  CRErrorCodeInvalidState = -101,
} CRErrorCode;

/*!
 CRRecorder options.
 */
typedef enum : NSUInteger {
  CRRecorderOptionUserRecording = 1 << 0, // Record the user using the front facing camera
  CRRecorderOptionTouchRecording = 1 << 1, // Record touches
} CRRecorderOptions;

/*!
 Save result block.
 @param URL Asset URL. To load the ALAsset, use ALAssetsLibrary assetForURL:resultBlock:failureBlock.
 */
typedef void (^CRRecorderSaveResultBlock)(NSURL *URL);

/*!
 Save failure block.
 @param error Error
 */
typedef void (^CRRecorderSaveFailureBlock)(NSError *error);
