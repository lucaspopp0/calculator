//
//  ExceptionHandler.h
//  Calc Pro
//
//  Created by Lucas Popp on 10/2/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExceptionHandler : NSObject

+ (BOOL)handleException:(void(^)())tryBlock error:(__autoreleasing NSError **)error;

@end
