//
//  ViewController.m
//  DCPhotoPicker
//
//  Created by Derek Carter on 1/6/16.
//  Copyright © 2016 Derek Carter. All rights reserved.
//

#import "DemoViewController.h"
#import "DCPhotoPicker.h"
#import <Photos/Photos.h>

@interface DemoViewController () <DCPhotoPickerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) DCPhotoPicker *photoPicker;

@end

@implementation DemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                NSLog(@"PHAuthorizationStatusAuthorized");
                break;
            case PHAuthorizationStatusRestricted:
                NSLog(@"PHAuthorizationStatusRestricted");
                [self presentAlertWithTitle:@"Need permission to access photos."
                                withMessage:@""];
                break;
            case PHAuthorizationStatusDenied:
                [self presentAlertWithTitle:@"Need permission to access photos."
                                withMessage:@""];
                break;
            default:
                break;
        }
    }];
}


#pragma mark - Actions

- (IBAction)openPhotoPicker:(id)sender
{
    _photoPicker = [[DCPhotoPicker alloc] initWithTitle:@"Photo Library"
                                         alternateTitle:@"Use Selected Photo"
                                            otherTitles:@[ @"Take Photo", @"Do Something", @"Do Something Else" ]
                                            cancelTitle:@"Cancel"];
    _photoPicker.delegate = self;
    _photoPicker.themeColor = [UIColor colorWithRed:23/255.0f green:163/255.0f blue:209/255.0f alpha:1.0f];
    _photoPicker.maxSelectCount = 1;
    _photoPicker.buttonFont = [UIFont systemFontOfSize:19.0f];
    _photoPicker.buttonFontColor = [UIColor colorWithRed:23/255.0f green:163/255.0f blue:209/255.0f alpha:1.0f];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _photoPicker.modalPresentationStyle = UIModalPresentationPopover;
        _photoPicker.popoverPresentationController.sourceView = self.view;
        _photoPicker.popoverPresentationController.sourceRect = CGRectMake(self.view.center.x, self.view.center.y, 400, 400);
    }
    
    [self presentViewController:_photoPicker animated:YES completion:nil];
}

- (IBAction)pageTurn:(UIPageControl *)pageControl
{
    int whichPage = (int)pageControl.currentPage;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * whichPage, 0.0f);
    [UIView commitAnimations];
}


#pragma mark - DCPhotoPickerDelegate Methods

- (BOOL)photoPickerShouldDismissWithAssets:(NSArray *)assets
{
    NSLog(@"DemoViewController | photoPickerShouldDismissWithAssets");
    return YES;
}

- (void)photoPickerAssetsSelected:(NSArray *)assets
{
    NSLog(@"DemoViewController | photoPickerAssetsSelected");
    
    if (assets) {
        PHImageManager *imageManager = [PHImageManager defaultManager];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        
        __block NSUInteger count = 0;
        __block NSMutableArray *images = [NSMutableArray new];
        for (PHAsset *asset in assets) {
            @autoreleasepool {
                [imageManager requestImageForAsset:asset
                                        targetSize:PHImageManagerMaximumSize
                                       contentMode:PHImageContentModeAspectFill
                                           options:options
                                     resultHandler:^(UIImage *image, NSDictionary *info) {
                                         if (image) {
                                             [images addObject:image];
                                         }
                                         count++;
                                         
                                         if (count == [assets count]) {
                                             [self addImagesToScrollView:images];
                                         }
                                     }];
            }
        }
    }
}

- (void)photoPickerButtonItemClicked:(NSInteger)itemIndex
{
    NSLog(@"DemoViewController | photoPickerButtonItemClicked");
    
    switch (itemIndex) {
        case 0:
            NSLog(@"Selected photo library");
            break;
        case 1:
            NSLog(@"Selected camera");
            break;
        default:
            NSLog(@"Button not accounted for");
            break;
    }
}

- (void)photoPickerWillDismiss
{
    NSLog(@"DemoViewController | photoPickerWillDismiss");
}

- (void)photoPickerDidDismiss
{
    NSLog(@"DemoViewController | photoPickerDidDismiss");
    _photoPicker = nil;
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page != -1 && page != 3) {
        self.pageControl.currentPage = page;
    }
}


#pragma mark - Helper Methods

- (void)addImagesToScrollView:(NSArray *)images
{
    if (!images || ![images count]) {
        NSLog(@"No images to load");
        return;
    }
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if ([images count] > 1) {
        self.pageControl.numberOfPages = [images count];
    } else {
        self.pageControl.numberOfPages = 0;
    }
    
    UIImageView *previousImageView;
    for (UIImage *image in images) {
        UIImageView *imageView = [UIImageView new];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.scrollView addSubview:imageView];
        [self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView(==scrollView)]"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{
                                                                                           @"imageView": imageView,
                                                                                           @"scrollView": self.scrollView
                                                                                           }]];
        
        if (!previousImageView) { // Pin the first to the left
            [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView(==scrollView)]"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{
                                                                                              @"imageView": imageView,
                                                                                              @"scrollView": self.scrollView
                                                                                              }]];
        } else { // Pin the rest to the previous item
            [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousImageView][imageView(==scrollView)]"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{
                                                                                              @"previousImageView": previousImageView,
                                                                                              @"imageView": imageView,
                                                                                              @"scrollView": self.scrollView
                                                                                              }]];
        }
        previousImageView = imageView;
    }
    
    // Pin to the bottom and right
    [self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousImageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{
                                                                                       @"previousImageView": previousImageView
                                                                                       }]];
    [self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousImageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{
                                                                                       @"previousImageView": previousImageView
                                                                                       }]];
}

- (void)presentAlertWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil];
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
