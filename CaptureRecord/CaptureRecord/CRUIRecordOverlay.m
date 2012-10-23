//
//  CRUIRecordOverlay.m
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 9/3/12.
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

#import "CRUIRecordOverlay.h"
#import "CRRecorder.h"
#import "CRUtils.h"

typedef enum {
  CRUIButtonStyleDefault = 1,
  CRUIButtonStylePrimary,
  CRUIButtonStyleStart,
  CRUIButtonStyleWarning,
  CRUIButtonStyleDanger,
} CRUIButtonStyle;

@implementation CRUIRecordOverlay

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.opaque = NO;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    //
    // Record view
    //
    
    _recordBackground = [[CRUIButton alloc] init];
    _recordBackground.color = [UIColor colorWithWhite:0.0 alpha:0.7];
    _recordBackground.cornerRadius = 10.0;
    [self addSubview:_recordBackground];
    
    _startButton = [self buttonWithTitle:@"Start Recording" action:@selector(_start) style:CRUIButtonStyleStart];
    [_recordBackground addSubview:_startButton];
    
    /*
    _resumeButton = [self buttonWithTitle:@"Resume" action:@selector(_resume) style:CRUIButtonStyleStart];
    _resumeButton.hidden = YES;
    [_recordBackground addSubview:_resumeButton];
    
    _pauseButton = [self buttonWithTitle:@"Pause" action:@selector(_pause) style:CRUIButtonStylePause];
    _pauseButton.hidden = YES;
    [_recordBackground addSubview:_pauseButton];
     */
    
    _stopButton = [self buttonWithTitle:@"Stop Recording" action:@selector(_stop) style:CRUIButtonStyleDanger];
    _stopButton.hidden = YES;
    [_recordBackground addSubview:_stopButton];
    
    _closeButton = [self buttonWithTitle:@"Close" action:@selector(_close) style:CRUIButtonStyleDefault];
    [_recordBackground addSubview:_closeButton];
    
    //
    // Save view
    //
    
    _saveBackground = [[CRUIButton alloc] init];
    _saveBackground.color = [UIColor colorWithWhite:0.0 alpha:0.7];
    _saveBackground.cornerRadius = 10.0;
    _saveBackground.hidden = YES;
    [self addSubview:_saveBackground];
    
    _saveLabel = [[UILabel alloc] init];
    [_saveBackground addSubview:_saveLabel];

    _saveButton = [self buttonWithTitle:@"Save Video" action:@selector(_save) style:CRUIButtonStylePrimary];
    [_saveBackground addSubview:_saveButton];
    
    _discardButton = [self buttonWithTitle:@"Discard Video" action:@selector(_discard) style:CRUIButtonStyleWarning];
    [_saveBackground addSubview:_discardButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateForVideoNotification:) name:CRVideoDidChangeNotification object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat x = 10;
  CGFloat y = 10;
  CGFloat buttonWidth = 180;

  if (!_startButton.hidden) {
    _startButton.frame = CGRectMake(x, y, buttonWidth, 44);
    y += 54;
  }
  
  /*
  if (!_resumeButton.hidden) {
    _resumeButton.frame = CGRectMake(x, y, buttonWidth, 44);
    y += 54;
  }
  
  if (!_pauseButton.hidden) {
    _pauseButton.frame = CGRectMake(x, y, buttonWidth, 44);
    y += 54;
  }
   */
  
  if (!_stopButton.hidden) {
    _stopButton.frame = CGRectMake(x, y, buttonWidth, 44);
    y += 54;
  }
  
  if (!_closeButton.hidden) {
    _closeButton.frame = CGRectMake(x, y, buttonWidth, 44);
    y += 54;
  }
  
  _recordBackground.frame = CGRectMake(60, 120, buttonWidth + 20, y);
    
  x = 10;
  y = 10;
  
  _saveButton.frame = CGRectMake(x, y, buttonWidth, 44);
  y += 54;
  
  _discardButton.frame = CGRectMake(x, y, buttonWidth, 44);
  y += 54;
  
  _saveBackground.frame = CGRectMake(60, 120, buttonWidth + 20, y);
}

- (CRUIButton *)buttonWithTitle:(NSString *)title action:(SEL)action style:(CRUIButtonStyle)style {
  CRUIButton *button = [[CRUIButton alloc] initWithFrame:CGRectZero title:title target:self action:action];
  button.borderWidth = 1.0;
  button.cornerRadius = 6.0;
  button.titleFont = [UIFont boldSystemFontOfSize:16.0];
  button.shadingType = CRUIShadingTypeLinear;
  button.highlightedShadingType = CRUIShadingTypeLinear;
  button.disabledTitleShadowColor = [UIColor colorWithWhite:0 alpha:0];
  button.disabledShadingType = CRUIShadingTypeNone;
  button.disabledColor = [UIColor colorWithWhite:239.0f/255.0f alpha:1.0f];
  button.disabledTitleColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
  button.disabledBorderColor = [UIColor colorWithWhite:216.0f/255.0f alpha:1.0f];
  button.title = title;
  
  switch (style) {
    case CRUIButtonStyleDefault:
      button.titleShadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
      button.titleShadowOffset = CGSizeMake(0, -1);
      button.titleColor = [UIColor colorWithWhite:51.0f/255.0f alpha:1.0];
      button.color = [UIColor whiteColor];
      button.color2 = [UIColor colorWithWhite:0.9 alpha:1.0];
      button.titleColor = [UIColor colorWithWhite:51.0f/255.0f alpha:1.0];
      button.borderColor = [UIColor colorWithWhite:184.0f/255.0f alpha:1.0];
      button.highlightedColor = [UIColor colorWithWhite:203.0f/255.0f alpha:1.0];
      button.highlightedColor2 = [UIColor colorWithWhite:230.0f/255.0f alpha:1.0];
      break;
    case CRUIButtonStylePrimary:
      button.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
      button.titleShadowOffset = CGSizeMake(0, -1);
      button.titleColor = [UIColor whiteColor];
      button.color = [UIColor colorWithRed:0.0f/255.0f green:133.0f/255.0f blue:204.0f/255.0f alpha:1.0];
      button.color2 = [UIColor colorWithRed:0.0f/255.0f green:69.0f/255.0f blue:204.0f/255.0f alpha:1.0];
      button.borderColor = [UIColor colorWithRed:1.0f/255.0f green:82.0f/255.0f blue:154.0f/255.0f alpha:1.0];
      button.highlightedColor = [UIColor colorWithRed:0.0f/255.0f green:60.0f/255.0f blue:180.0f/255.0f alpha:1.0];
      button.highlightedColor2 = [UIColor colorWithRed:0.0f/255.0f green:68.0f/255.0f blue:204.0f/255.0f alpha:1.0];
      break;
    case CRUIButtonStyleStart:
      button.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
      button.titleShadowOffset = CGSizeMake(0, -1);
      button.titleColor = [UIColor whiteColor];
      button.color = [UIColor colorWithRed:97.0f/255.0f green:194.0f/255.0f blue:97.0f/255.0f alpha:1.0];
      button.color2 = [UIColor colorWithRed:81.0f/255.0f green:164.0f/255.0f blue:81.0f/255.0f alpha:1.0];
      button.borderColor = [UIColor colorWithRed:69.0f/255.0f green:138.0f/255.0f blue:69.0f/255.0f alpha:1.0];
      button.highlightedColor = [UIColor colorWithRed:71.0f/255.0f green:143.0f/255.0f blue:71.0f/255.0f alpha:1.0];
      button.highlightedColor2 = [UIColor colorWithRed:81.0f/255.0f green:163.0f/255.0f blue:81.0f/255.0f alpha:1.0];
      break;
    case CRUIButtonStyleWarning:
      button.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
      button.titleShadowOffset = CGSizeMake(0, -1);
      button.cornerRadius = 6.0;
      button.titleColor = [UIColor whiteColor];
      button.color = [UIColor colorWithRed:251.0f/255.0f green:178.0f/255.0f blue:76.0f/255.0f alpha:1.0];
      button.color2 = [UIColor colorWithRed:248.0f/255.0f green:149.0f/255.0f blue:7.0f/255.0f alpha:1.0];
      button.borderColor = [UIColor colorWithRed:188.0f/255.0f green:126.0f/255.0f blue:38.0f/255.0f alpha:1.0];
      button.highlightedColor = [UIColor colorWithRed:218.0f/255.0f green:130.0f/255.0f blue:5.0f/255.0f alpha:1.0];
      button.highlightedColor2 = [UIColor colorWithRed:248.0f/255.0f green:148.0f/255.0f blue:6.0f/255.0f alpha:1.0];
      break;
    case CRUIButtonStyleDanger:
      button.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
      button.titleShadowOffset = CGSizeMake(0, -1);  
      button.titleColor = [UIColor whiteColor];
      button.color = [UIColor colorWithRed:236.0f/255.0f green:93.0f/255.0f blue:89.0f/255.0f alpha:1.0];
      button.color2 = [UIColor colorWithRed:190.0f/255.0f green:55.0f/255.0f blue:48.0f/255.0f alpha:1.0];
      button.borderColor = [UIColor colorWithRed:164.0f/255.0f green:60.0f/255.0f blue:55.0f/255.0f alpha:1.0];
      button.highlightedColor = [UIColor colorWithRed:166.0f/255.0f green:47.0f/255.0f blue:41.0f/255.0f alpha:1.0];
      button.highlightedColor2 = [UIColor colorWithRed:189.0f/255.0f green:54.0f/255.0f blue:47.0f/255.0f alpha:1.0];
      break;
  }
  return button;
}

- (void)_start {
  if (![[CRRecorder sharedRecorder] isRecording]) {
    [[CRRecorder sharedRecorder] start:nil];
    [self _close:NO];
  }
}

- (void)_stop {
  if ([[CRRecorder sharedRecorder] isRecording]) {
    [[CRRecorder sharedRecorder] stop:nil];
  } else {
    [self _close:NO];
  }
}

- (void)_alertError:(NSError *)error {
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alertView show];
}

- (void)_save {
  [[CRRecorder sharedRecorder] saveVideoToAlbumWithResultBlock:^(NSURL *URL) {
    
  } failureBlock:^(NSError *error) {
    [self _alertError:error];
  }];
}

- (void)_discard {
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to discard the video?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Discard", nil];
  [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1) {
    [self _discardConfirmed];
  }
}

- (void)_discardConfirmed {
  [[CRRecorder sharedRecorder] discardVideo:nil];
  [self _close:NO];
}

- (void)_close {
  [self _close:NO];
}

- (void)_close:(BOOL)delayed {
  if (delayed) {
    CRDispatchAfter(0.1, ^(){
      self.hidden = YES;
    });
  } else {
    self.hidden = YES;
  }    
}

- (void)_updateForVideoNotification:(NSNotification *)notification {
  CRVideo *video = [notification object];
  [self _updateForStatus:video.status];
}

- (void)_reset {
  _recordBackground.hidden = NO;
  _saveBackground.hidden = YES;
  _startButton.enabled = YES;
  _startButton.hidden = NO;
  _stopButton.hidden = YES;
}
 
- (void)_updateForStatus:(CRVideoStatus)status {
  switch (status) {
    case CRVideoStatusNone:
      [self _reset];
      break;
    case CRVideoStatusStarted:
      _recordBackground.hidden = NO;
      _saveBackground.hidden = YES;
      _startButton.hidden = YES;
      _stopButton.hidden = NO;
      break;
    case CRVideoStatusStopped:
      _recordBackground.hidden = YES;
      _saveBackground.hidden = NO;
      _saveButton.title = @"Save Video";
      _saveButton.enabled = YES;
      break;
    case CRVideoStatusSaving:
      _saveButton.title = @"Saving...";
      _saveButton.enabled = NO;
      break;
    case CRVideoStatusSaved:
      [self _reset];
      [self _close:NO];
      break;
    case CRVideoStatusDiscarded:
      [self _reset];
      [self _close:NO];
      break;
  }
  [self setNeedsDisplay];
  [self setNeedsLayout];
}

@end