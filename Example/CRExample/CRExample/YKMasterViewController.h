//
//  YKMasterViewController.h
//  CRExample
//
//  Created by Gabriel Handford on 9/10/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YKDetailViewController;

@interface YKMasterViewController : UITableViewController

@property (strong, nonatomic) YKDetailViewController *detailViewController;

@end
