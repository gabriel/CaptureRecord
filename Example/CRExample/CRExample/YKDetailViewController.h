//
//  YKDetailViewController.h
//  CRExample
//
//  Created by Gabriel Handford on 9/10/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YKDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
