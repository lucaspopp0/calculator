//
//  AboutViewController.m
//  Calculator Pro
//
//  Created by Lucas Popp on 11/29/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *icons8Link = [[UIButton alloc] initWithFrame:CGRectMake(16.0f, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 8.0f,
                                                                      self.view.frame.size.width - 32.0f, 31.0f)];
    [icons8Link setTitle:@"Icons 8" forState:UIControlStateNormal];
    [icons8Link setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
    [icons8Link addTarget:self action:@selector(openIcons8Link) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:icons8Link];
    
}

- (void)openIcons8Link {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.icons8.com/"]];
}

@end
