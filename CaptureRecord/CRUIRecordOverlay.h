//
//  CRUIRecordOverlay.h
//  CaptureRecord
//
//  Created by Gabriel Handford on 9/3/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import "CRUIButton.h"

@interface CRUIRecordOverlay : UIView {
  CRUIButton *_recordBackground;
  CRUIButton *_startButton;
  //CRUIButton *_pauseButton;
  //CRUIButton *_resumeButton;
  CRUIButton *_stopButton;
  CRUIButton *_closeButton;
  
  CRUIButton *_saveBackground;
  UILabel *_saveLabel;
  CRUIButton *_saveButton;
  CRUIButton *_discardButton;
}

@end