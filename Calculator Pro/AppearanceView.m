//
//  AppearanceView.m
//  Calculator Pro
//
//  Created by Lucas Popp on 10/28/15.
//  Copyright © 2015 Lucas Popp. All rights reserved.
//

#import "AppearanceView.h"
#import "ColorSwatch.h"
#import "LinePreview.h"

@interface AppearanceView ()

@property (strong, nonatomic) UISegmentedControl *dashSegmentedControl;
@property (strong, nonatomic) UIScrollView *swatchesView;
@property (strong, nonatomic) NSMutableArray *swatches;
@property (strong, nonatomic) NSMutableArray *swatchColors;
@property (strong, nonatomic) UISlider *lineThicknessSlider;

@end

@implementation AppearanceView

- (id)init {
    if (self == [super init]) {
        self.frame = CGRectMake(0.0f, 0.0f, 275.0f, 162.0f);
        self.backgroundColor = [UIColor whiteColor];
        
        self.dashSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"SOLID", @"DASHED"]];
        self.dashSegmentedControl.frame = CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, 31.0f);
        self.dashSegmentedControl.tintColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
        
        [self addSubview:self.dashSegmentedControl];
        
        [self.dashSegmentedControl addTarget:self action:@selector(setLineDash) forControlEvents:UIControlEventValueChanged];
        
        self.swatchColors = [[NSMutableArray alloc] init];
        [self.swatchColors addObject:[UIColor colorWithRed:1.0f green:0.2f blue:0.2f alpha:1.0f]];
        [self.swatchColors addObject:[UIColor colorWithRed:1.0f green:0.5f blue:0.2f alpha:1.0f]];
        [self.swatchColors addObject:[UIColor colorWithRed:1.0f green:0.8f blue:0.2f alpha:1.0f]];
        [self.swatchColors addObject:[UIColor colorWithRed:0.2f green:0.75f blue:0.2f alpha:1.0f]];
        [self.swatchColors addObject:[UIColor colorWithRed:0.2f green:0.2f blue:1.0f alpha:1.0f]];
        [self.swatchColors addObject:[UIColor colorWithRed:0.5f green:0.2f blue:1.0f alpha:1.0f]];
        [self.swatchColors addObject:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
        
        self.swatchesView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, self.dashSegmentedControl.frame.origin.y + self.dashSegmentedControl.frame.size.height + 8.0f, self.frame.size.width, 44.0f)];
        self.swatchesView.showsHorizontalScrollIndicator = NO;
        self.swatchesView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.swatchesView];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectSwatch:)];
        
        [self.swatchesView addGestureRecognizer:tapRecognizer];
        
        self.swatches = [[NSMutableArray alloc] init];
        
        for (int i = 0;i < self.swatchColors.count;i++) {
            UIColor *color = (UIColor *)self.swatchColors[i];
            ColorSwatch *swatch = [[ColorSwatch alloc] initWithFrame:CGRectMake(8.0f + ((float)i * 44.0f), 0.0f, 44.0f, 44.0f)];
            
            swatch.color = color;
            
            [self.swatches addObject:swatch];
            [self.swatchesView addSubview:swatch];
            
            self.swatchesView.contentSize = CGSizeMake(swatch.frame.origin.x + swatch.frame.size.width + 8.0f, 44.0f);
        }
        
        LinePreview *thinPreview = [[LinePreview alloc] initWithFrame:CGRectMake(self.dashSegmentedControl.frame.origin.x, self.swatchesView.frame.origin.y + self.swatchesView.frame.size.height + 8.0f, 16.0f, 16.0f)];
        LinePreview *mediumPreview = [[LinePreview alloc] initWithFrame:CGRectMake((self.frame.size.width - 16.0f) / 2.0f, self.swatchesView.frame.origin.y + self.swatchesView.frame.size.height + 8.0f, 16.0f, 16.0f)];
        LinePreview *thickPreview = [[LinePreview alloc] initWithFrame:CGRectMake(self.dashSegmentedControl.frame.origin.x + self.dashSegmentedControl.frame.size.width - 16.0f, self.swatchesView.frame.origin.y + self.swatchesView.frame.size.height + 8.0f, 16.0f, 16.0f)];
        
        thinPreview.thickness = 1.5f;
        mediumPreview.thickness = 2.25f;
        thickPreview.thickness = 3.0f;
        
        [self addSubview:thinPreview];
        [self addSubview:mediumPreview];
        [self addSubview:thickPreview];
        
        self.lineThicknessSlider = [[UISlider alloc] initWithFrame:CGRectMake(self.dashSegmentedControl.frame.origin.x, thickPreview.frame.origin.y + thickPreview.frame.size.height + 8.0f, self.dashSegmentedControl.frame.size.width, 31.0f)];
        self.lineThicknessSlider.minimumValue = 1.0f;
        self.lineThicknessSlider.maximumValue = 3.0f;
        self.lineThicknessSlider.continuous = YES;
        [self.lineThicknessSlider addTarget:self action:@selector(setThickness) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:self.lineThicknessSlider];
    }
    
    return self;
}

- (void)setThickness {
    self.lineThicknessSlider.value = round(self.lineThicknessSlider.value);
    
    self.line.lineThickness = 0.75f * (round(self.lineThicknessSlider.value) + 1.0f);
}

- (void)setSelectedSwatch:(int)ind {
    ColorSwatch *swatch;
    
    for (int i = 0;i < self.swatches.count;i++) {
        swatch = (ColorSwatch *)self.swatches[i];
        
        if (i == ind) {
            swatch.swatchSelected = YES;
            self.line.lineColor = swatch.color;
        } else {
            swatch.swatchSelected = NO;
        }
    }
}

- (void)selectSwatch:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint touchLocation = [sender locationInView:self.swatchesView];
        
        for (ColorSwatch *swatch in self.swatches) {
            if (CGRectContainsPoint(swatch.frame, touchLocation)) {
                swatch.swatchSelected = YES;
                self.line.lineColor = swatch.color;
            } else {
                swatch.swatchSelected = NO;
            }
        }
    }
}

- (void)setLineDash {
    if (self.dashSegmentedControl.selectedSegmentIndex == 0) {
        self.line.lineDashed = NO;
    } else {
        self.line.lineDashed = YES;
    }
}

- (void)prepare {
    ColorSwatch *swatch;
    
    for (int i = 0;i < self.swatches.count;i++) {
        swatch = (ColorSwatch *)self.swatches[i];
        
        if ([swatch.color isEqual:self.line.lineColor]) {
            swatch.swatchSelected = YES;
        } else {
            swatch.swatchSelected = NO;
        }
    }
    
    self.lineThicknessSlider.value = round(self.line.lineThickness / 0.75f) - 1.0f;
    
    if (self.line.lineDashed) {
        self.dashSegmentedControl.selectedSegmentIndex = 1;
    } else {
        self.dashSegmentedControl.selectedSegmentIndex = 0;
    }
}

@end
