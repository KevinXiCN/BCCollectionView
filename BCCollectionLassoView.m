//
//  BCCollectionLassoView.m
//  BCCollectionView
//
//  Created by Kevin Xi on 10/07/16.
//  Copyright (c) 2016 Kevin Xi. All rights reserved.
//

#import "BCCollectionLassoView.h"

@implementation BCCollectionLassoView

@synthesize backgroundColor;
@synthesize borderColor;
@synthesize borderSize;

// Set the default values.
- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.2f];
        borderColor = [NSColor colorWithRed:237/255.0 green:236/255.0 blue:237/255.0 alpha:1];
        borderSize = 1.0f;
    }
    
    return self;
}

// Draw white background and a border.
- (void)drawRect:(NSRect)dirtyRect
{
    dirtyRect = self.bounds;

    // fill with background color.
    NSBezierPath *rect = [NSBezierPath bezierPathWithRect:dirtyRect];
    [self.backgroundColor set];
    [rect fill];
    
    // draw border lines.
    if (self.borderSize > 0) {
        [rect setLineWidth:self.borderSize];
        [self.borderColor set];
        [rect stroke];
    }
    
    [super drawRect:dirtyRect];
}

@end
