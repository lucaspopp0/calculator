//
//  ViewController.h
//  Calculator Pro
//
//  Created by Lucas Popp on 9/29/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) NSString *constant;
- (void)analyzeGraphTouchAt:(float)x;

@end

