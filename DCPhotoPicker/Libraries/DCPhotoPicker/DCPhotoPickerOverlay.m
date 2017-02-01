//
//  DCPhotoPickerOverlay.m
//  PhotoPicker
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import "DCPhotoPickerOverlay.h"
#import "DCPhotoPickerCheckmarkView.h"

static float const kCheckmarkDiameter = 30.0f;
static float const kBottomAndRightSidePadding = 4.0f;
static float const kOverlayBorderWidth = 2.0f;

@implementation DCPhotoPickerOverlay
{
    DCPhotoPickerCheckmarkView *_checkmark;
}

- (id)initWithFrame:(CGRect)frame andThemeColor:(UIColor *)themeColor
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!themeColor) {
            themeColor = [UIColor colorWithRed:20/255.0 green:111/255.0 blue:223/255.0 alpha:1];
        }
        
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.33];
        self.layer.borderColor = [themeColor CGColor];
        self.layer.borderWidth = kOverlayBorderWidth;
        
        _checkmark = [[DCPhotoPickerCheckmarkView alloc] initWithFrame:CGRectMake(self.frame.size.width - (kBottomAndRightSidePadding + kCheckmarkDiameter), self.frame.size.height - (kBottomAndRightSidePadding + kCheckmarkDiameter), kCheckmarkDiameter, kCheckmarkDiameter)];
        _checkmark.themeColor = themeColor;
        _checkmark.autoresizingMask = UIViewAutoresizingNone;
        _checkmark.layer.shadowColor = [[UIColor blackColor] CGColor];
        _checkmark.layer.shadowOffset = CGSizeMake(0, 0);
        _checkmark.layer.shadowOpacity = 0.5;
        _checkmark.layer.shadowRadius = 2.0;
        [self addSubview:_checkmark];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _checkmark.frame = CGRectMake(self.frame.size.width - (kBottomAndRightSidePadding + kCheckmarkDiameter),
                                  self.frame.size.height - (kBottomAndRightSidePadding + kCheckmarkDiameter),
                                  kCheckmarkDiameter, kCheckmarkDiameter);
}

- (void)dealloc
{
    //NSLog(@"%s", __func__);
}

@end
