//
//  DCPhotoPickerAnimationController.h
//  PhotoPicker
//
//  Created by Derek Carter on 1/5/16.
//  Copyright © 2016 Derek Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DCPhotoPicker.h"

@interface DCPhotoPickerAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

- (id)initWithViewController:(DCPhotoPicker *)viewController isPresenting:(BOOL)presenting;

@end
