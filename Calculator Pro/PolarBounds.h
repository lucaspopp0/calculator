//
//  PolarBounds.h
//  Calculator Pro
//
//  Created by Lucas Popp on 3/28/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PolarBounds : NSObject

@property (nonatomic, assign) double tmin;
@property (nonatomic, assign) double tmax;
@property (nonatomic, assign) double tstep;

@property (nonatomic, assign) double xmin;
@property (nonatomic, assign) double xmax;
@property (nonatomic, assign) double xstep;

@property (nonatomic, assign) double ymin;
@property (nonatomic, assign) double ymax;
@property (nonatomic, assign) double ystep;

@end
