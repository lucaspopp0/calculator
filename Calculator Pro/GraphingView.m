//
//  GraphingView.m
//  Calculator Pro
//
//  Created by Lucas Popp on 10/23/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "GraphingView.h"
#import "Calculator.h"
#import "ViewController.h"

@interface GraphingView ()

@property (strong, nonatomic) Calculator *calc;

@property (nonatomic) float xRange;
@property (nonatomic) float yRange;

@property (nonatomic) float xScale;
@property (nonatomic) float yScale;

@property (nonatomic) float lastY;
@property (nonatomic) float lastLastY;

@property (strong, nonatomic) NSMutableArray *shapeLayers;
@property (strong, nonatomic) NSMutableArray *paths;

@property (strong, nonatomic) CAShapeLayer *scrubbingLayer;

@property (strong, nonatomic) NSMutableArray *scrubbingCircles;

@property (strong, nonatomic) NSMutableArray *intersections;
@property (strong, nonatomic) NSMutableArray *probableIntersections;
@property (strong, nonatomic) NSMutableArray *intersectionCircles;

@property (nonatomic) BOOL shouldGraph;

@property (nonatomic) float totalGraphed;

@end

@implementation GraphingView

- (id)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        self.calc = [[Calculator alloc] init];
        
        self.shouldGraph = YES;
        
        self.tMin = 0.0f;
        self.tMax = 360.0f;
        
        self.xMin = -15.0f;
        self.xMax = 15.0f;
        
        self.yMin = -10.0f;
        self.yMax = 10.0f;
        
        self.tStep = 7.5f;
        self.xStep = 3.0f;
        self.yStep = 3.0f;
        
        self.lines = [[NSArray alloc] init];
        self.paths = [[NSMutableArray alloc] init];
        self.shapeLayers = [[NSMutableArray alloc] init];
        
        self.equationsUpdated = YES;
        
        self.scrubbingLayer = [[CAShapeLayer alloc] init];
        self.scrubbingLayer.lineWidth = 1.0f;
        self.scrubbingLayer.strokeColor = [UIColor blackColor].CGColor;
        
        [self.layer addSublayer:self.scrubbingLayer];
        
        self.scrubbingCircles = [[NSMutableArray alloc] init];
        
        self.intersections = [[NSMutableArray alloc] init];
        self.probableIntersections = [[NSMutableArray alloc] init];
        self.intersectionCircles = [[NSMutableArray alloc] init];
        
        self.layer.masksToBounds = YES;
        self.clipsToBounds = YES;
    }
    
    return self;
}

- (void)refreshGraph {
    [self drawGraph];
}

- (void)clearScrubbing {
    self.scrubbingLayer.hidden = YES;
    
    for (UIView *circle in self.scrubbingCircles) {
        [circle removeFromSuperview];
    }
    
    [self.scrubbingCircles removeAllObjects];
}

- (void)clearPOI {
    for (UIView *circle in self.intersectionCircles) {
        [circle removeFromSuperview];
    }
    
    [self.intersectionCircles removeAllObjects];
    [self.intersections removeAllObjects];
    [self.probableIntersections removeAllObjects];
}

- (void)drawGraph {
    self.equationsUpdated = NO;
    
    self.xRange = self.xMax - self.xMin;
    self.yRange = self.yMax - self.yMin;
    
    self.xScale = self.xRange / self.frame.size.width;
    self.yScale = self.yRange / self.frame.size.height;
    
    for (CAShapeLayer *layer in self.shapeLayers) {
        [layer removeFromSuperlayer];
    }
    
    [self.shapeLayers removeAllObjects];
    [self.paths removeAllObjects];
    
    [self clearScrubbing];
    [self clearPOI];
    
    [self drawAxes];
    
    [self performSelectorInBackground:@selector(handleLines) withObject:nil];
    
    for (int i = 0;i < self.lines.count;i++) {
        UIView *scrubbingCircle = [[UIView alloc] initWithFrame:CGRectMake(-100.0f, 0.0f, 6.0f, 6.0f)];
        scrubbingCircle.layer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;
        scrubbingCircle.layer.cornerRadius = scrubbingCircle.frame.size.width / 2.0f;
        scrubbingCircle.userInteractionEnabled = NO;
        
        [self.scrubbingCircles addObject:scrubbingCircle];
        [self addSubview:scrubbingCircle];
    }
}

- (void)stopGraphing {
    self.shouldGraph = NO;
}

- (void)handleLines {
    self.shouldGraph = YES;
    
    for (int eq = 0;eq < self.lines.count;eq++) {
        if (!self.shouldGraph) {
            self.shouldGraph = YES;
            break;
        }
        
        [self handleLine:self.lines[eq]];
    }
}

- (void)handleLine:(NSDictionary *)eq {
    if ([eq[@"Equation"] isEqual:@""]) {
        return;
    } else if (![eq[@"Equation"] containsString:@"x"]) {
        float y = [self.calc getDoubleValueOfExpression:[self.calc evaluateString:eq[@"Equation"]]];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        [path moveToPoint:[self pointOnGraphWithX:self.xMin andY:y]];
        [path addLineToPoint:[self pointOnGraphWithX:self.xMax andY:y]];
        
        [self.paths addObject:path];
        
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.path = path.CGPath;
        shapeLayer.lineWidth = [eq[@"Thickness"] floatValue];
        shapeLayer.strokeColor = ((UIColor *)eq[@"Color"]).CGColor;
        [self.shapeLayers addObject:shapeLayer];
        
        [self.layer addSublayer:shapeLayer];
    } else {
        float increment = self.xRange / 800.0f;
        
        for (float x = self.xMin - (2.0f * increment);x <= self.xMax + (2.0f * increment);x += increment) {
            [self performSelectorOnMainThread:@selector(drawLineAt:) withObject:@{
                                                                                  @"x" : @(x),
                                                                                  @"Equation" : eq[@"Equation"],
                                                                                  @"Increment" : @(increment),
                                                                                  @"Color" : eq[@"Color"],
                                                                                  @"Thickness" : eq[@"Thickness"],
                                                                                  @"Dashed" : eq[@"Dashed"]
                                                                                  } waitUntilDone:YES];
        }
    }
}

- (void)drawAxes {
    if ([self pointOnGraphWithX:self.xMin + self.xStep andY:0.0f].x > 20.0f) {
        for (float x = self.xStep / 2.0f;x <= self.xMax;x += self.xStep) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            
            CGPoint topPoint = [self pointOnGraphWithX:x andY:0];
            topPoint.y += 2.0f;
            
            CGPoint bottomPoint = [self pointOnGraphWithX:x andY:0];
            bottomPoint.y -= 2.0f;
            
            [path moveToPoint:topPoint];
            [path addLineToPoint:bottomPoint];
            
            [self.paths addObject:path];
            
            CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
            shapeLayer.path = path.CGPath;
            shapeLayer.lineWidth = 1.0f;
            shapeLayer.strokeColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
            [self.shapeLayers addObject:shapeLayer];
            
            [self.layer addSublayer:shapeLayer];
        }
        
        for (float x = self.xStep / 2.0f;x >= self.xMin;x -= self.xStep) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            
            CGPoint topPoint = [self pointOnGraphWithX:x andY:0];
            topPoint.y += 2.0f;
            
            CGPoint bottomPoint = [self pointOnGraphWithX:x andY:0];
            bottomPoint.y -= 2.0f;
            
            [path moveToPoint:topPoint];
            [path addLineToPoint:bottomPoint];
            
            [self.paths addObject:path];
            
            CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
            shapeLayer.path = path.CGPath;
            shapeLayer.lineWidth = 1.0f;
            shapeLayer.strokeColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
            [self.shapeLayers addObject:shapeLayer];
            
            [self.layer addSublayer:shapeLayer];
        }
        
        for (float y = self.yStep / 2.0f;y <= self.yMax;y += self.yStep) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            
            CGPoint leftPoint = [self pointOnGraphWithX:0 andY:y];
            leftPoint.x -= 2.0f;
            
            CGPoint rightPoint = [self pointOnGraphWithX:0 andY:y];
            rightPoint.x += 2.0f;
            
            [path moveToPoint:leftPoint];
            [path addLineToPoint:rightPoint];
            
            [self.paths addObject:path];
            
            CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
            shapeLayer.path = path.CGPath;
            shapeLayer.lineWidth = 1.0f;
            shapeLayer.strokeColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
            [self.shapeLayers addObject:shapeLayer];
            
            [self.layer addSublayer:shapeLayer];
        }
        
        for (float y = self.yStep / 2.0f;y >= self.yMin;y -= self.yStep) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            
            CGPoint leftPoint = [self pointOnGraphWithX:0 andY:y];
            leftPoint.x -= 2.0f;
            
            CGPoint rightPoint = [self pointOnGraphWithX:0 andY:y];
            rightPoint.x += 2.0f;
            
            [path moveToPoint:leftPoint];
            [path addLineToPoint:rightPoint];
            
            [self.paths addObject:path];
            
            CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
            shapeLayer.path = path.CGPath;
            shapeLayer.lineWidth = 1.0f;
            shapeLayer.strokeColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
            [self.shapeLayers addObject:shapeLayer];
            
            [self.layer addSublayer:shapeLayer];
        }
    }
    
    UIBezierPath *xAxis = [UIBezierPath bezierPath];
    
    [xAxis moveToPoint:[self pointOnGraphWithX:self.xMin andY:0.0f]];
    [xAxis addLineToPoint:[self pointOnGraphWithX:self.xMax andY:0.0f]];
    
    [self.paths addObject:xAxis];
    
    CAShapeLayer *xLayer = [[CAShapeLayer alloc] init];
    xLayer.path = xAxis.CGPath;
    xLayer.lineWidth = 1.0f;
    xLayer.strokeColor = [UIColor blackColor].CGColor;
    [self.shapeLayers addObject:xLayer];
    
    [self.layer addSublayer:xLayer];
    
    UIBezierPath *yAxis = [UIBezierPath bezierPath];
    
    [yAxis moveToPoint:[self pointOnGraphWithX:0.0f andY:self.yMin]];
    [yAxis addLineToPoint:[self pointOnGraphWithX:0.0f andY:self.yMax]];
    
    [self.paths addObject:yAxis];
    
    CAShapeLayer *yLayer = [[CAShapeLayer alloc] init];
    yLayer.path = yAxis.CGPath;
    yLayer.lineWidth = 1.0f;
    yLayer.strokeColor = [UIColor blackColor].CGColor;
    [self.shapeLayers addObject:yLayer];
    
    [self.layer addSublayer:yLayer];
    
    for (float x = 0;x <= self.xMax;x += self.xStep) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        CGPoint topPoint = [self pointOnGraphWithX:x andY:0];
        topPoint.y += 3.0f;
        
        CGPoint bottomPoint = [self pointOnGraphWithX:x andY:0];
        bottomPoint.y -= 3.0f;
        
        [path moveToPoint:topPoint];
        [path addLineToPoint:bottomPoint];
        
        [self.paths addObject:path];
        
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.path = path.CGPath;
        shapeLayer.lineWidth = 1.0f;
        shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        [self.shapeLayers addObject:shapeLayer];
        
        [self.layer addSublayer:shapeLayer];
    }
    
    for (float x = 0;x >= self.xMin;x -= self.xStep) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        CGPoint topPoint = [self pointOnGraphWithX:x andY:0];
        topPoint.y += 3.0f;
        
        CGPoint bottomPoint = [self pointOnGraphWithX:x andY:0];
        bottomPoint.y -= 3.0f;
        
        [path moveToPoint:topPoint];
        [path addLineToPoint:bottomPoint];
        
        [self.paths addObject:path];
        
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.path = path.CGPath;
        shapeLayer.lineWidth = 1.0f;
        shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        [self.shapeLayers addObject:shapeLayer];
        
        [self.layer addSublayer:shapeLayer];
        
    }
    
    for (float y = 0;y <= self.yMax;y += self.yStep) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        CGPoint leftPoint = [self pointOnGraphWithX:0 andY:y];
        leftPoint.x -= 3.0f;
        
        CGPoint rightPoint = [self pointOnGraphWithX:0 andY:y];
        rightPoint.x += 3.0f;
        
        [path moveToPoint:leftPoint];
        [path addLineToPoint:rightPoint];
        
        [self.paths addObject:path];
        
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.path = path.CGPath;
        shapeLayer.lineWidth = 1.0f;
        shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        [self.shapeLayers addObject:shapeLayer];
        
        [self.layer addSublayer:shapeLayer];
    }
    
    for (float y = 0;y >= self.yMin;y -= self.yStep) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        CGPoint leftPoint = [self pointOnGraphWithX:0 andY:y];
        leftPoint.x -= 3.0f;
        
        CGPoint rightPoint = [self pointOnGraphWithX:0 andY:y];
        rightPoint.x += 3.0f;
        
        [path moveToPoint:leftPoint];
        [path addLineToPoint:rightPoint];
        
        [self.paths addObject:path];
        
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.path = path.CGPath;
        shapeLayer.lineWidth = 1.0f;
        shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        [self.shapeLayers addObject:shapeLayer];
        
        [self.layer addSublayer:shapeLayer];
    }
}

- (void)drawLineAt:(NSDictionary *)information searchForDiscontinuities:(BOOL)searching {
    float x = [information[@"x"] floatValue];
    NSString *equation = information[@"Equation"];
    float increment = [information[@"Increment"] floatValue];
    UIColor *color = information[@"Color"];
    float thickness = [information[@"Thickness"] floatValue];
    BOOL dashed = [information[@"Dashed"] boolValue];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    float y = [self.calc getDoubleValueEfficientlyOfExpression:equation withVariable:@"x" value:x];
    float lastY = self.lastY;
    float lastLastY = self.lastLastY;
    
    if (x <= self.xMin) {
        lastY = [self.calc getDoubleValueEfficientlyOfExpression:equation withVariable:@"x" value:x - increment];
        lastLastY = [self.calc getDoubleValueEfficientlyOfExpression:equation withVariable:@"x" value:x - (2.0f * increment)];
        
        self.totalGraphed = 0.0f;
    }
    
    if (isnan(y) && isnan(lastY)) {
        //
    } else {
        if (y != NAN && ((self.yMin <= y && y <= self.yMax) || (self.yMin <= lastY && lastY <= self.yMax))) {
            float lastSlope = (lastY - lastLastY) / increment;
            float currentSlope = (y - lastY) / increment;
            
            if ([self.calc posNegOrZero:lastSlope] == [self.calc posNegOrZero:currentSlope]) {
                if (fabsf(y - lastY) < 5.0f * self.yScale) {
                    CGPoint currentPoint = [self pointOnGraphWithX:x andY:y];
                    CGPoint lastPoint = [self pointOnGraphWithX:(x - increment) andY:lastY];
                    
                    [path moveToPoint:currentPoint];
                    [path addLineToPoint:lastPoint];
                    
                    [self.paths addObject:path];
                    
                    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
                    shapeLayer.path = path.CGPath;
                    shapeLayer.lineWidth = thickness;
                    shapeLayer.strokeColor = color.CGColor;
                    
                    [self.shapeLayers addObject:shapeLayer];
                    [self.layer insertSublayer:shapeLayer below:[self.layer.sublayers firstObject]];
                    
                    if (dashed) {
                        if ((int)roundf(self.totalGraphed / 5.0f) % 2 == 0) {
                            shapeLayer.opacity = 0.0f;
                        }
                        
                        self.totalGraphed += sqrtf(powf(currentPoint.x - lastPoint.x, 2.0f) + powf(currentPoint.y - lastPoint.y, 2.0f));
                    }
                } else {
                    for (float x2 = x - increment;x2 <= x;x2 += (increment / 100.0f)) {
                        [self performSelectorOnMainThread:@selector(drawLineAt:searchForDiscontinuities:) withObject:@{
                                                                                                                       @"x" : @(x2),
                                                                                                                       @"Equation" : equation,
                                                                                                                       @"Increment" : @(increment / 100.0f),
                                                                                                                       @"Color" : color,
                                                                                                                       @"Thickness" : @(thickness),
                                                                                                                       @"Dashed" : @(dashed)
                                                                                                                       } waitUntilDone:YES];
                    }
                }
            } else if (searching) {
                for (float x2 = x - increment;x2 <= x;x2 += (increment / 100.0f)) {
                    [self performSelectorOnMainThread:@selector(drawLineAt:searchForDiscontinuities:) withObject:@{
                                                                                                                   @"x" : @(x2),
                                                                                                                   @"Equation" : equation,
                                                                                                                   @"Increment" : @(increment / 100.0f),
                                                                                                                   @"Color" : color,
                                                                                                                   @"Thickness" : @(thickness),
                                                                                                                   @"Dashed" : @(dashed)
                                                                                                                   } waitUntilDone:YES];
                }
            }
        }
    }
    
    self.lastLastY = lastY;
    self.lastY = y;
}

- (void)drawLineAt:(NSDictionary *)information {
    [self drawLineAt:information searchForDiscontinuities:YES];
}

- (CGPoint)valueFromGraphPoint:(CGPoint)original {
    float x = ((original.x / self.frame.size.width) * self.xRange) + self.xMin;
    float y = ((fabs(original.y - self.frame.size.height) / self.frame.size.height) * self.yRange) + self.yMin;
    
    return CGPointMake(x, y);
}

- (CGPoint)pointOnGraphWithX:(float)x andY:(float)y {
    float graphicalX = ((x - self.xMin) / self.xRange) * self.frame.size.width;
    float graphicalY = self.frame.size.height - (((y - self.yMin) / self.yRange) * self.frame.size.height);
    
    return CGPointMake(graphicalX, graphicalY);
}

- (CGPoint)pointOnGraph:(CGPoint)point {
    return [self pointOnGraphWithX:point.x andY:point.y];
}

- (void)positionScrubbing:(float)x {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(x, 0.0f)];
    [path addLineToPoint:CGPointMake(x, self.frame.size.height)];
    
    self.scrubbingLayer.path = path.CGPath;
    self.scrubbingLayer.hidden = NO;
    
    float x2 = [self valueFromGraphPoint:CGPointMake(x, 0.0f)].x;
    
    for (int i = 0;i < self.lines.count;i++) {
        float y = [self.calc getDoubleValueEfficientlyOfExpression:self.lines[i][@"Equation"] withVariable:@"x" value:x2];
        
        if (y != NAN) {
            CGPoint realPoint = [self pointOnGraphWithX:x2 andY:y];
            
            [self.scrubbingCircles[i] setFrame:CGRectMake(realPoint.x - ([self.scrubbingCircles[i] frame].size.width / 2.0f), realPoint.y - ([self.scrubbingCircles[i] frame].size.height / 2.0f), [self.scrubbingCircles[i] frame].size.width, [self.scrubbingCircles[i] frame].size.height)];
        } else {
            [self.scrubbingCircles[i] setFrame:CGRectMake(-100.0f, 0.0f, 6.0f, 6.0f)];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    
    CGPoint graphValue = [self valueFromGraphPoint:touchLocation];
    
    [self positionScrubbing:touchLocation.x];
    
    [((ViewController *)self.superview.nextResponder) analyzeGraphTouchAt:graphValue.x];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    
    CGPoint graphValue = [self valueFromGraphPoint:touchLocation];
    
    [self positionScrubbing:touchLocation.x];
    
    [((ViewController *)self.superview.nextResponder) analyzeGraphTouchAt:graphValue.x];
}

- (BOOL)probablyHasAsymptoteAt:(float)x equation:(NSString *)eq increment:(float)increment {
    float y = [self.calc getDoubleValueEfficientlyOfExpression:eq withVariable:@"x" value:x];
    
    if (y != NAN) {
        float lastY = [self.calc getDoubleValueEfficientlyOfExpression:eq withVariable:@"x" value:x - increment];
        float lastLastY = [self.calc getDoubleValueEfficientlyOfExpression:eq withVariable:@"x" value:x - (2.0f * increment)];
        
        float lastSlope = (lastY - lastLastY) / increment;
        float currentSlope = (y - lastY) / increment;
        
        return ([self.calc posNegOrZero:lastSlope] != [self.calc posNegOrZero:currentSlope]);
    }
    
    return YES;
}

- (void)searchForPointsOfIntersection {
    for (UIView *circle in self.intersectionCircles) {
        [circle removeFromSuperview];
    }
    
    [self.intersectionCircles removeAllObjects];
    
    NSMutableArray *combinationsTried = [[NSMutableArray alloc] init];
    
    NSDictionary *line;
    NSDictionary *line2;
    
    for (int i = 0;i < self.lines.count;i++) {
        line = self.lines[i];
        
        for (int j = 0;j < self.lines.count;j++) {
            line2 = self.lines[j];
            
            NSString *combination = [NSString stringWithFormat:@"%i-%i", i, j];
            NSString *combination2 = [NSString stringWithFormat:@"%i-%i", j, i];
            
            if (i != j && ![combinationsTried containsObject:combination] && ![combinationsTried containsObject:combination2]) {
                [combinationsTried addObject:combination];
                
                float increment = self.xRange / 800.0f;
                
                [self searchForIntersectionBetween:line[@"Equation"] and:line2[@"Equation"] from:self.xMin - (2.0f * increment) to:self.xMax + (2.0f * increment) increment:increment continueSearching:YES];
            }
        }
    }
}

- (void)drawIntersectionAtPoint:(CGPoint)center {
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(center.x - 3.0f, center.y - 3.0f, 6.0f, 6.0f)];
    circle.layer.borderColor = [UIColor blackColor].CGColor;
    circle.layer.borderWidth = 1.0f;
    circle.layer.cornerRadius = 3.0f;
    
    [self.intersectionCircles addObject:circle];
    [self addSubview:circle];
}

- (void)searchForIntersectionBetween:(NSString *)eq1 and:(NSString *)eq2 from:(float)startX to:(float)endX increment:(float)increment {
    [self searchForIntersectionBetween:eq1 and:eq2 from:startX to:endX increment:increment continueSearching:NO];
}

- (void)searchForIntersectionBetween:(NSString *)eq1 and:(NSString *)eq2 from:(float)startX to:(float)endX increment:(float)increment continueSearching:(BOOL)continueSearching {
    for (float x = startX;x <= endX + increment;x += increment) {
        float leftX = x - increment;
        float leftY1 = [self.calc getDoubleValueEfficientlyOfExpression:eq1 withVariable:@"x" value:leftX];
        float rightY1 = [self.calc getDoubleValueEfficientlyOfExpression:eq1 withVariable:@"x" value:x];
        float leftY2 = [self.calc getDoubleValueEfficientlyOfExpression:eq2 withVariable:@"x" value:leftX];
        float rightY2 = [self.calc getDoubleValueEfficientlyOfExpression:eq2 withVariable:@"x" value:x];
        
        CGPoint left1 = CGPointMake(leftX, leftY1);
        CGPoint right1 = CGPointMake(x, rightY1);
        CGPoint left2 = CGPointMake(leftX, leftY2);
        CGPoint right2 = CGPointMake(x, rightY2);
        
        BOOL probablyHasAsymptote = ([self probablyHasAsymptoteAt:leftX equation:eq1 increment:increment] ||
                                     [self probablyHasAsymptoteAt:x equation:eq1 increment:increment] ||
                                     [self probablyHasAsymptoteAt:leftX equation:eq2 increment:increment] ||
                                     [self probablyHasAsymptoteAt:x equation:eq2 increment:increment]);
        
        if (!probablyHasAsymptote && [self probablyContainsIntersectionWithRadius:increment start1:left1 end:right1 start:left2 end:right2]) {
            if (continueSearching) {
                [self searchForIntersectionBetween:eq1 and:eq2 from:x - increment to:x increment:increment / 100.0f];
            } else {
                CGPoint center = [self pointOnGraphWithX:x andY:rightY1];
                [self drawIntersectionAtPoint:center];
            }
        }
    }
}

- (void)probableIntersectionFoundWithCenter:(CGPoint)center radius:(float)radius eq1:(NSString *)eq1 eq2:(NSString *)eq2 {
    [self.probableIntersections addObject:@{
                                            @"x" : @(center.x),
                                            @"y" : @(center.y),
                                            @"r" : @(radius),
                                            @"eq1" : eq1,
                                            @"eq2" : eq2
                                            }];
}

- (void)findIntersectionNearProbableIntersection:(NSDictionary *)probableIntersection {
    float cx = [probableIntersection[@"x"] floatValue];
    float cy = [probableIntersection[@"x"] floatValue];
    float r = [probableIntersection[@"x"] floatValue];
    NSString *eq1 = probableIntersection[@"eq1"];
    NSString *eq2 = probableIntersection[@"eq2"];
    
    for (float x = cx - r;x <= cx + r;x += 1.0f / MAXFLOAT) {
        if ([self.calc getDoubleValueEfficientlyOfExpression:eq1 withVariable:@"x" value:x] == [self.calc getDoubleValueEfficientlyOfExpression:eq2 withVariable:@"x" value:x]) {
#warning Unfinished method implementation
        }
    }
}

- (BOOL)probablyContainsIntersectionWithRadius:(float)radius start1:(CGPoint)start1 end:(CGPoint)end1 start:(CGPoint)start2 end:(CGPoint)end2 {
    return ([self shortestDistanceBetweenLinesWithStart:start1 end:end1 start:start2 end:end2] <= 0.0f || [self linesCross:start1 end:end1 start:start2 end:end2]);
}

- (CGPoint)centerOfPoints:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 p4:(CGPoint)p4 {
    return CGPointMake((p1.x + p2.x + p3.x + p4.x) / 4.0f,
                       (p1.y + p2.y + p3.y + p4.y) / 4.0f);
}

- (BOOL)linesCross:(CGPoint)start1 end:(CGPoint)end1 start:(CGPoint)start2 end:(CGPoint)end2 {
    return ((start1.y < start2.y && end1.y > end2.y) || (start1.y > start2.y && end1.y < end2.y) || (start1.y == start2.y && end1.y == end2.y));
}

- (double)shortestDistanceBetweenLinesWithStart:(CGPoint)start1 end:(CGPoint)end1 start:(CGPoint)start2 end:(CGPoint)end2 {
    NSMutableArray *distances = [[NSMutableArray alloc] init];
    
    [distances addObject:@([self distanceBetweenPointAndLine:start1 leftPoint:start2 rightPoint:end2])];
    [distances addObject:@([self distanceBetweenPointAndLine:end1 leftPoint:start2 rightPoint:end2])];
    [distances addObject:@([self distanceBetweenPointAndLine:start2 leftPoint:start1 rightPoint:end1])];
    [distances addObject:@([self distanceBetweenPointAndLine:end2 leftPoint:start1 rightPoint:end1])];
    
    float shortestDistance = [distances[0] floatValue];
    
    for (int i = 0;i < distances.count;i++) {
        float distance = [distances[i] floatValue];
        
        if (distance < shortestDistance) {
            shortestDistance = distance;
        }
    }
    
    return shortestDistance;
}

- (double)distanceBetweenPointAndLine:(CGPoint)point leftPoint:(CGPoint)left rightPoint:(CGPoint)right {
    if (CGPointEqualToPoint(point, left) || CGPointEqualToPoint(point, right)) {
        return 0.0f;
    } else if (left.y == right.y) {
        return fabs(point.y - left.y);
    } else {
        float dx = fabs(left.x - right.x);
        float dy = fabs(left.y - right.y);
        
        float theta = atan(dx / dy);
        
        if (point.x == left.x) {
            if ((point.y < left.y && left.y < right.y) || (point.y > left.y && left.y > right.y)) {
                return fabs(point.y - left.y);
            } else {
                return sin(theta) * fabs(point.y - left.y);
            }
        } else if (point.x == right.x) {
            if ((point.y < right.y && right.y < left.y) || (point.y > right.y && right.y > left.y)) {
                return fabs(point.y - right.y);
            } else {
                return sin(theta) * fabs(point.y - right.y);
            }
        } else {
            return NAN;
        }
    }
}

@end
