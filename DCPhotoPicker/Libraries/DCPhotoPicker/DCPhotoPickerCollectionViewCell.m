//
//  DCPhotoPickerCollectionViewCell.m
//  PhotoPicker
//
//  Created by Derek Carter on 12/30/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import "DCPhotoPickerCollectionViewCell.h"
#import "DCPhotoPickerOverlay.h"

@interface DCPhotoPickerCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) DCPhotoPickerOverlay *overlayView;

@end


@implementation DCPhotoPickerCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.themeColor = [UIColor colorWithRed:20/255.0 green:111/255.0 blue:223/255.0 alpha:1];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:imageView];

        self.imageView = imageView;
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        [self hideOverlayView];
        [self showOverlayView];
    } else {
        [self hideOverlayView];
    }
}


#pragma mark - Overlay View Methods

- (void)showOverlayView
{
    DCPhotoPickerOverlay *overlayView = [[DCPhotoPickerOverlay alloc] initWithFrame:self.contentView.bounds andThemeColor:self.themeColor];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:overlayView];
    
    self.overlayView = overlayView;
}

- (void)hideOverlayView
{
    [self.overlayView removeFromSuperview];
    self.overlayView = nil;
}


#pragma mark - Accessor Methods

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

@end

