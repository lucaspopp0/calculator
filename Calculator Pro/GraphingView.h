//
//  GraphingView.h
//  Calculator Pro
//
//  Created by Lucas Popp on 10/23/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphingView : UIView

@property (strong, nonatomic) NSArray *lines;

@property (nonatomic, assign) BOOL equationsUpdated;

- (id)initWithFrame:(CGRect)frame;

- (void)refreshGraph;
- (void)searchForPointsOfIntersection;
- (void)clearPOI;

@property (nonatomic) float tMin;
@property (nonatomic) float tMax;
@property (nonatomic) float xMin;
@property (nonatomic) float xMax;
@property (nonatomic) float yMin;
@property (nonatomic) float yMax;

@property (nonatomic) float tStep;
@property (nonatomic) float xStep;
@property (nonatomic) float yStep;

- (void)stopGraphing;

@end
