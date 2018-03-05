//
//  WindowManager.h
//  Calculator Pro
//
//  Created by Lucas Popp on 3/28/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunctionBounds.h"
#import "PolarBounds.h"

@interface WindowManager : NSObject

@property (strong, nonatomic) FunctionBounds *functionBounds;
@property (strong, nonatomic) PolarBounds *polarBounds;

@end
