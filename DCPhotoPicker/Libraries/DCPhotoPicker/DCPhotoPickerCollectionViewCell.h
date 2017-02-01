//
//  DCPhotoPickerCollectionViewCell.h
//  PhotoPicker
//
//  Created by Derek Carter on 12/30/15.
//  Copyright © 2015 Derek Carter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCPhotoPickerCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *assetIdentifier;
@property (nonatomic, strong) UIColor *themeColor;

@end
