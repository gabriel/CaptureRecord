//
//  CRScreenRecorder.h
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/16/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import "CRRecordable.h"

/*!
 Recorder for the screen.
 
 @warning This uses a private API (UIGetScreenImage), and is not available in the simulator.
 */
@interface CRScreenRecorder : NSObject <CRRecordable> {
  void *_CRGetScreenImage; // Function pointer for UIGetScreenImage
  CGSize _size;
}

@end