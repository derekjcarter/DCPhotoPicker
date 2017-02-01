//
//  DCPhotoPickerCheckmarkView.m
//  PhotoPicker
//
//  Created by Derek Carter on 12/30/15.
//  Copyright © 2015 Gogo LLC. All rights reserved.
//

#import "DCPhotoPickerCheckmarkView.h"

static float const kBorderWidth = 1.0f;
static float const kCheckmarkLineWidth = 1.2f;

@implementation DCPhotoPickerCheckmarkView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.themeColor = [UIColor colorWithRed:20/255.0 green:111/255.0 blue:223/255.0 alpha:1];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *checkmarkBGColor = self.themeColor;
    
    CGRect group = CGRectMake(CGRectGetMinX(rect) + 3, CGRectGetMinY(rect) + 3, CGRectGetWidth(rect) - 6, CGRectGetHeight(rect) - 6);
    
    UIBezierPath *checkedOvalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetMinX(group) + floor(CGRectGetWidth(group) * 0.00000 + 0.5), CGRectGetMinY(group) + floor(CGRectGetHeight(group) * 0.00000 + 0.5), floor(CGRectGetWidth(group) * 1.00000 + 0.5) - floor(CGRectGetWidth(group) * 0.00000 + 0.5), floor(CGRectGetHeight(group) * 1.00000 + 0.5) - floor(CGRectGetHeight(group) * 0.00000 + 0.5))];
    CGContextSaveGState(context);
    [checkmarkBGColor setFill];
    [checkedOvalPath fill];
    CGContextRestoreGState(context);
    
    [[UIColor whiteColor] setStroke];
    checkedOvalPath.lineWidth = kBorderWidth;
    [checkedOvalPath stroke];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(group) + 0.27083 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.54167 * CGRectGetHeight(group))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(group) + 0.41667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.68750 * CGRectGetHeight(group))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(group) + 0.75000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.35417 * CGRectGetHeight(group))];
    bezierPath.lineCapStyle = kCGLineCapSquare;
    
    [[UIColor whiteColor] setStroke];
    bezierPath.lineWidth = kCheckmarkLineWidth;
    [bezierPath stroke];
}

- (void)dealloc
{
    //NSLog(@"%s", __func__);
}

@end
