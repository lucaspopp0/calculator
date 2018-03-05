//
//  ModeView.m
//  Calculator Pro
//
//  Created by Lucas Popp on 10/28/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "ModeView.h"

@interface ModeView ()

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation ModeView

- (id)init {
    if (self == [super init]) {
        self.frame = CGRectMake(0.0f, 0.0f, 275.0f, 150.0f);
        self.backgroundColor = [UIColor whiteColor];
        self.defaults = [NSUserDefaults standardUserDefaults];
        
        self.radDegSegmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, 31.0f)];
        [self.radDegSegmentedControl insertSegmentWithTitle:@"DEGREES" atIndex:0 animated:NO];
        [self.radDegSegmentedControl insertSegmentWithTitle:@"RADIANS" atIndex:0 animated:NO];
        self.radDegSegmentedControl.tintColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
        
        if ([[self.defaults objectForKey:@"Radians or Degrees"] isEqual:@"Degrees"]) {
            [self.radDegSegmentedControl setSelectedSegmentIndex:1];
        } else {
            [self.radDegSegmentedControl setSelectedSegmentIndex:0];
        }
        
        [self addSubview:self.radDegSegmentedControl];
        
        self.graphTypeSegmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(8.0f, self.radDegSegmentedControl.frame.origin.y + self.radDegSegmentedControl.frame.size.height + 8.0f, self.frame.size.width - 16.0f, 31.0f)];
        [self.graphTypeSegmentedControl insertSegmentWithTitle:@"POLAR" atIndex:0 animated:NO];
        [self.graphTypeSegmentedControl insertSegmentWithTitle:@"FUNCTION" atIndex:0 animated:NO];
        self.graphTypeSegmentedControl.tintColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
        
        if ([[self.defaults objectForKey:@"Graphing Type"] isEqual:@"Polar"]) {
            [self.graphTypeSegmentedControl setSelectedSegmentIndex:1];
        } else {
            [self.graphTypeSegmentedControl setSelectedSegmentIndex:0];
        }
        
        [self addSubview:self.graphTypeSegmentedControl];
    }
    
    return self;
}

@end
