//
//  ExceptionHandler.m
//  Calc Pro
//
//  Created by Lucas Popp on 10/2/16.
//  Copyright © 2016 Lucas Popp. All rights reserved.
//

#import "ExceptionHandler.h"

@implementation ExceptionHandler

+ (BOOL)handleException:(void(^)())tryBlock error:(__autoreleasing NSError **)error {
    @try {
        tryBlock();
        return YES;
    } @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:exception.userInfo];
    }
}

@end
