//
//  DCPhotoPickerOverlay.h
//  PhotoPicker
//
//  Created by Derek Carter on 12/4/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCPhotoPickerOverlay : UIView

@property (nonatomic, strong) UIColor *themeColor;

- (id)initWithFrame:(CGRect)frame andThemeColor:(UIColor *)themeColor;

@end
