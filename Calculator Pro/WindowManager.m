//
//  WindowManager.m
//  Calculator Pro
//
//  Created by Lucas Popp on 3/28/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

#import "WindowManager.h"

@implementation WindowManager

- (id)init {
    if (self == [super init]) {
        // Function bounds
        self.functionBounds.xmin = -15;
        self.functionBounds.xmax = 15;
        self.functionBounds.xstep = 3;
        
        self.functionBounds.ymin = -10;
        self.functionBounds.ymax = 10;
        self.functionBounds.ystep = 3;
        
        // Polar bounds
        self.polarBounds.tmin = 0;
        self.polarBounds.tmax = 360;
        self.polarBounds.tstep = 7.5;
        
        self.polarBounds.xmin = -15;
        self.polarBounds.xmax = 15;
        self.polarBounds.xstep = 3;
        
        self.polarBounds.ymin = -10;
        self.polarBounds.ymax = 10;
        self.polarBounds.ystep = 3;
    }
    
    return self;
}

@end
