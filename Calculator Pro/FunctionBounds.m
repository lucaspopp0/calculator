//
//  FunctionBounds.m
//  Calculator Pro
//
//  Created by Lucas Popp on 3/28/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

#import "FunctionBounds.h"

@implementation FunctionBounds

- (id)initWithXMin:(double)xMin xMax:(double)xMax xStep:(double)xStep yMin:(double)yMin yMax:(double)yMax yStep:(double)yStep {
    if (self == [super init]) {
        self.xmin = xMin;
        self.xmax = xMax;
        self.xstep = xStep;
        
        self.ymin = yMin;
        self.ymax = yMax;
        self.ystep = yStep;
    }
    
    return self;
}

@end
