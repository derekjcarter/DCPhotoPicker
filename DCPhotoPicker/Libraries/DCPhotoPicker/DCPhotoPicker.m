//
//  DCPhotoPicker.m
//  PhotoPicker
//
//  Created by Derek Carter on 1/5/16.
//  Copyright © 2016 Derek Carter. All rights reserved.
//

#import "DCPhotoPicker.h"
#import "DCPhotoPickerCollectionViewCell.h"
#import "DCPhotoPickerAnimationController.h"


static NSString *const kCellReuseIdentifier    = @"PhotoPickerCell";
static int const kMaxNumberOfImages            = 50;
static float const kThumbnailImageSize         = 150.0f;
static float const kPhotosCollectionViewHeight = 155.0f;
static float const kButtonHeight               = 44.0f;


@interface DCPhotoPicker () <UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UICollectionView *photosCollectionView;
@property (nonatomic, strong) UIButton *firstButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *otherButtonsContainer;

@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) NSMutableArray *selectedAssets;

@end


@implementation DCPhotoPicker
{
    NSString *_selectTitle;
    NSString *_alternateSelectTitle;
    NSString *_cancelTitle;
    NSArray *_buttonItems;
}

- (id)initWithTitle:(NSString *)title alternateTitle:(NSString *)altTitle otherTitles:(NSArray *)otherTitles cancelTitle:(NSString *)cancelTitle
{
    NSLog(@"%s", __func__);
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        
        _selectTitle = title;
        _alternateSelectTitle = altTitle;
        _buttonItems = otherTitles;
        _cancelTitle = cancelTitle;
        
        // Defaults
        _maxSelectCount = 1;
        _themeColor = [UIColor blueColor];
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"%s", __func__);
    [super viewDidLoad];
    
    // Photo image manager
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized ) {
        self.imageManager = [[PHCachingImageManager alloc] init];
    }
    
    // Photo fetching
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];
    allPhotosOptions.fetchLimit = kMaxNumberOfImages;
    self.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    
    // Selected assets datasource
    self.selectedAssets = [NSMutableArray new];
    
    // General view properties
    self.view.backgroundColor = [UIColor clearColor];
    
    // Background view
    _backgroundView = [UIView new];
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2723];
    [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonTapped:)]];
    [self.view addSubview:_backgroundView];
    
    // Container view
    _containerView = [UIView new];
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        _containerView.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.userInteractionEnabled = NO;
        blurEffectView.frame = _containerView.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_containerView addSubview:blurEffectView];
    } else {
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    _containerView.layer.cornerRadius = 15.0f;
    _containerView.layer.masksToBounds = YES;
    [self.view addSubview:_containerView];
    
    // Photos collection view
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    _photosCollectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    [_photosCollectionView registerClass:[DCPhotoPickerCollectionViewCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
    _photosCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _photosCollectionView.backgroundColor = [UIColor clearColor];
    _photosCollectionView.alwaysBounceHorizontal = YES;
    _photosCollectionView.showsHorizontalScrollIndicator = NO;
    if (_maxSelectCount > 1) {
        _photosCollectionView.allowsMultipleSelection = YES;
    } else {
        _photosCollectionView.allowsMultipleSelection = NO;
    }
    _photosCollectionView.dataSource = self;
    _photosCollectionView.delegate = self;
    [_containerView addSubview:_photosCollectionView];
    
    // First select button
    _firstButton = [UIButton new];
    _firstButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_firstButton setTitle:_selectTitle forState:UIControlStateNormal];
    [_firstButton addTarget:self action:@selector(firstButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_firstButton];
    
    // Cancel button
    _cancelButton = [UIButton new];
    _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_cancelButton setTitle:_cancelTitle forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_cancelButton];
    
    // Other buttons
    _otherButtonsContainer = [UIButton new];
    _otherButtonsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [_containerView addSubview:_otherButtonsContainer];
    for (int i = 0; i < _buttonItems.count; i++) {
        [self addButton:_buttonItems[i] atIndex:i];
    }
    
    // Calculate the height of container..
    float otherButtonsContainerViewHeight = _buttonItems.count * kButtonHeight;
    float containerViewHeight = kPhotosCollectionViewHeight + (kButtonHeight * 2) + otherButtonsContainerViewHeight;
    
    
    
    
    // Constraint views
    NSDictionary *views = NSDictionaryOfVariableBindings(_backgroundView, _containerView,_photosCollectionView, _firstButton, _otherButtonsContainer, _cancelButton);
    NSDictionary *metrics = @{
                              @"containerViewHeight" : @(containerViewHeight),
                              @"photosCollectionViewHeight" : @(kPhotosCollectionViewHeight),
                              @"buttonHeight" : @(kButtonHeight),
                              @"otherButtonsContainerViewHeight" : @(otherButtonsContainerViewHeight),
                              @"sidePadding" : @(10)
                              };
    
    // Horizontal constraints
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundView]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(sidePadding)-[_containerView]-(sidePadding)-|" options:0 metrics:metrics views:views]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_photosCollectionView]|" options:0 metrics:metrics views:views]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_firstButton]|" options:0 metrics:metrics views:views]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_otherButtonsContainer]|" options:0 metrics:metrics views:views]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cancelButton]|" options:0 metrics:metrics views:views]];
    
    // Vertical constraints
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundView]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_containerView(==containerViewHeight)]-(sidePadding)-|" options:0 metrics:metrics views:views]];
    
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_photosCollectionView(==photosCollectionViewHeight)][_firstButton(==buttonHeight)][_otherButtonsContainer(==otherButtonsContainerViewHeight)]" options:0 metrics:metrics views:views]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_cancelButton(==buttonHeight)]|" options:0 metrics:metrics views:views]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUserInterface];
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}


#pragma mark - Public Setter Methods

- (void)setMaxSelectCount:(NSInteger)maxSelectCount
{
    _maxSelectCount = maxSelectCount;
}

- (void)setThemeColor:(UIColor *)themeColor
{
    _themeColor = themeColor;
}


#pragma mark - Action Methods

- (void)firstButtonTapped:(id)sender
{
    if ([self.selectedAssets count] > 0) {
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(photoPickerShouldDismissWithAssets:)]) {
                if ([self.delegate photoPickerShouldDismissWithAssets:self.selectedAssets]) {
                    if([self.delegate respondsToSelector:@selector(photoPickerAssetsSelected:)]) {
                        [self.delegate photoPickerAssetsSelected:self.selectedAssets];
                    }
                    [self cancelButtonTapped:nil];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(photoPickerAssetsSelected:)]) {
                    [self.delegate photoPickerAssetsSelected:self.selectedAssets];
                }
                [self cancelButtonTapped:nil];
            }
        }
    } else {
        if (self.delegate) {
            [self.delegate photoPickerButtonItemClicked:0];
            [self cancelButtonTapped:nil];
        }
    }
}

- (void)otherButtonTapped:(id)sender
{
    if (self.delegate) {
        UIButton *button = (UIButton *)sender;
        [self.delegate photoPickerButtonItemClicked:(button.tag+1)];
        [self cancelButtonTapped:nil];
    }
}

- (void)cancelButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(photoPickerWillDismiss)]) {
        [self.delegate photoPickerWillDismiss];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(photoPickerDidDismiss)]) {
            [self.delegate photoPickerDidDismiss];
        }
    }];
}


#pragma mark - User Interface Methods

- (void)addButton:(NSString *)title atIndex:(NSInteger)bIndex
{
    UIButton *button = [UIButton new];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:title forState:UIControlStateNormal];
    button.tag = bIndex;
    [button addTarget:self action:@selector(otherButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addStyleToButton:button];
    [_otherButtonsContainer addSubview:button];
    
    [button addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0f
                                                        constant:kButtonHeight]];
    
    [_otherButtonsContainer addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_otherButtonsContainer
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0f
                                                                        constant:bIndex * kButtonHeight]];
    
    [_otherButtonsContainer addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                       attribute:NSLayoutAttributeLeftMargin
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_otherButtonsContainer
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1.0f
                                                                        constant:0.f]];
    
    [_otherButtonsContainer addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                       attribute:NSLayoutAttributeRightMargin
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_otherButtonsContainer
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0f
                                                                        constant:0.f]];
    
}

- (void)addStyleToButton:(UIButton *)button
{
    static UIImage *normalImage;
    static UIImage *selectedImage;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
        
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
        CGContextFillRect(context, rect);
        
        selectedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextFillRect(context, rect);
        
        normalImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    });
    
    [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    //[button setBackgroundImage:normalImage forState:UIControlStateNormal];
    
    if (self.buttonFontColor) {
        [button setTitleColor:self.buttonFontColor forState:UIControlStateNormal];
    } else if (_themeColor) {
        [button setTitleColor:_themeColor forState:UIControlStateNormal];
    } else {
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    
    if (self.buttonFont) {
        [button.titleLabel setFont:self.buttonFont];
    } else {
        [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    }
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, kButtonHeight, MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width), 1)];
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    [button addSubview:bottomBorder];
}

- (void)updateUserInterface
{
    [self addStyleToButton:_firstButton];
    [self addStyleToButton:_cancelButton];
    
   
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateAssetCount
{
    NSInteger cnt = [self.selectedAssets count];
    if (cnt > 0) {
        if([_alternateSelectTitle containsString:@"%ld"]) {
            [self.firstButton setTitle:[NSString stringWithFormat:_alternateSelectTitle,(long)cnt] forState:UIControlStateNormal];
        } else {
            [self.firstButton setTitle:_alternateSelectTitle forState:UIControlStateNormal];
        }
    } else {
        [self.firstButton setTitle:_selectTitle forState:UIControlStateNormal];
    }
}


#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetsFetchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    DCPhotoPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    cell.assetIdentifier = asset.localIdentifier;
    if (_themeColor) {
        cell.themeColor = _themeColor;
    }
    
    if (self.imageManager) {
        [self.imageManager requestImageForAsset:asset
                                     targetSize:CGSizeMake(kThumbnailImageSize, kThumbnailImageSize)
                                    contentMode:PHImageContentModeAspectFit
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      if ([cell.assetIdentifier isEqualToString:asset.localIdentifier]) {
                                          [cell setImage:result];
                                      }
                                  }];
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegate Methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.selectedAssets count] < _maxSelectCount || _maxSelectCount == 1) {
        return YES;
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    [self.selectedAssets addObject:asset];
    
    [self.photosCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    [self updateAssetCount];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    [self.selectedAssets removeObject:asset];
    
    [self.photosCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    [self updateAssetCount];
}


#pragma mark - UICollectionViewLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat borderHeight = 10;
    
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    float ration = (float)asset.pixelWidth / (float)asset.pixelHeight;
    
    CGSize size = CGSizeZero;
    size.height = kPhotosCollectionViewHeight - borderHeight;
    size.width =  ration * size.height;
    
    return size;
}


#pragma mark - UIViewControllerTransitioningDelegate Methods

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[DCPhotoPickerAnimationController alloc] initWithViewController:self isPresenting:YES];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[DCPhotoPickerAnimationController alloc] initWithViewController:self isPresenting:NO];
}


@end
