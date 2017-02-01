//
//  DCPhotoPicker.h
//  PhotoPicker
//
//  Created by Derek Carter on 1/5/16.
//  Copyright © 2016 Derek Carter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


@protocol DCPhotoPickerDelegate;


@interface DCPhotoPicker : UIViewController

@property (nonatomic, weak) id<DCPhotoPickerDelegate> delegate;
@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong, readonly) UIView *containerView;

@property (nonatomic, assign) NSInteger maxSelectCount;
@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, strong) UIFont *buttonFont;
@property (nonatomic, strong) UIColor *buttonFontColor;


- (id)initWithTitle:(NSString *)title alternateTitle:(NSString *)altTitle otherTitles:(NSArray *)otherTitles cancelTitle:(NSString *)cancelTitle;

@end


@protocol DCPhotoPickerDelegate <NSObject>

@optional
- (void)photoPickerButtonItemClicked:(NSInteger) itemInedx;
- (void)photoPickerAssetsSelected:(NSArray *)assets;
- (BOOL)photoPickerShouldDismissWithAssets:(NSArray *)assets;
- (void)photoPickerWillDismiss;
- (void)photoPickerDidDismiss;

@end