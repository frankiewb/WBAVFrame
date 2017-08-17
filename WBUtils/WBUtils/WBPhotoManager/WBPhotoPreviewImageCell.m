//
//  WBPhotoPreviewCell.m
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/19.
//  Copyright © 2016年 王博. All rights reserved.
//

#import "WBPhotoPreviewImageCell.h"
#import <PhotosUI/PhotosUI.h>
#import "WBPhotoConfiguration.h"
#import "UIView+WBUtils.h"
#import "WBPhotoManager.h"
#import "WBAssetModel.h"

@interface WBPhotoPreviewImageCell ()<UIScrollViewDelegate> {
    BOOL _isLivePhoto;
}

@property (strong, nonatomic) UIScrollView *myScrollView;

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) PHLivePhotoView *livePhotoView;

@property (strong, nonatomic) UIImageView *liveBadgeImageView;

@end

@implementation WBPhotoPreviewImageCell
#pragma mark - Inintialization Method
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self mp_setupSubview];
    }
    return self;
}

#pragma mark - Lazy Load
- (UIScrollView *)myScrollView {
    if (!_myScrollView) {
        self.myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, self.WB_width - 20, self.WB_height)];
        _myScrollView.bouncesZoom = YES;
        _myScrollView.minimumZoomScale = 1.f;
        _myScrollView.maximumZoomScale = 2.5f;
        _myScrollView.multipleTouchEnabled = YES;
        _myScrollView.scrollsToTop = NO;
        _myScrollView.showsHorizontalScrollIndicator = NO;
        _myScrollView.showsVerticalScrollIndicator = NO;
        _myScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _myScrollView.delaysContentTouches = NO;

        _myScrollView.delegate = self;
        
        [self addSubview:_myScrollView];
    }
    return _myScrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        self.imageView = [UIImageView new];
        _imageView.clipsToBounds = YES;
        
        [self.myScrollView addSubview:_imageView];
    }
    return _imageView;
}

- (PHLivePhotoView *)livePhotoView {
    if (!_livePhotoView) {
        self.livePhotoView = [PHLivePhotoView new];
        _livePhotoView.clipsToBounds = YES;
        
        [self.myScrollView addSubview:_livePhotoView];
    }
    return _livePhotoView;
}


- (UIImageView *)liveBadgeImageView {
    if (!_liveBadgeImageView) {
        self.liveBadgeImageView = [[UIImageView alloc] initWithImage:[PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent]];
        _liveBadgeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _liveBadgeImageView.clipsToBounds = YES;
        _liveBadgeImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _liveBadgeImageView.hidden = YES;
        [self.livePhotoView addSubview:_liveBadgeImageView];
        
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.livePhotoView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.livePhotoView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.livePhotoView attribute:NSLayoutAttributeLeading multiplier:1 constant:30];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.livePhotoView attribute:NSLayoutAttributeTop multiplier:1 constant:30];
        [self.livePhotoView addConstraints:@[leading, top, width, height]];
    }
    return _liveBadgeImageView;
}

#pragma mark - Setter
- (void)setModel:(WBAssetModel *)model {
    _model = model;
    
    self.imageView.image = nil;
    self.livePhotoView.livePhoto = nil;
    self.liveBadgeImageView.hidden = YES;
    
    if (model.type == WBAssetModelMediaTypeLivePhoto && [UIDevice currentDevice].systemVersion.floatValue >= 9.1 && [WBPhotoConfiguration defaultConfiguration].isCallBackLivePhoto) {
        _isLivePhoto = YES;
        
        [[WBPhotoManager defaultManager] getLivePhotoFromPHAsset:model.asset completionBlock:^(PHLivePhoto *livePhoto, BOOL isDegraded) {
            if (!isDegraded) {
                self.livePhotoView.livePhoto = livePhoto;
                if ([WBPhotoConfiguration defaultConfiguration].isShowLivePhotoIcon)
                    self.liveBadgeImageView.hidden = NO;
                [self mp_resizeSubviews];
            }
        }];
    } else {
        _isLivePhoto = NO;
        
        [[WBPhotoManager defaultManager] getPreviewImageFromPHAsset:model.asset isHighQuality:NO completionBlock:^(UIImage *result, NSDictionary *info, BOOL isDegraded) {
            self.imageView.image = result;
            [self mp_resizeSubviews];
        }];
    }
}

#pragma mark - Instance Methods
- (void)didDisplayed {
    if (!_isLivePhoto) {
        [[WBPhotoManager defaultManager] getPreviewImageFromPHAsset:_model.asset isHighQuality:YES completionBlock:^(UIImage *result, NSDictionary *info, BOOL isDegraded) {
            if (!isDegraded) {
                self.imageView.image = result;
                [self mp_resizeSubviews];
            }
        }];
    }
}

- (void)recoverSubviews {
    [self.myScrollView setZoomScale:1.0 animated:NO];
    [self mp_resizeSubviews];
}

- (void)mp_setupSubview {
    WBPhotoConfiguration *config = [WBPhotoConfiguration defaultConfiguration];
    switch (config.themeStyle) {
        case WBImagePickerStyleDark:
            self.myScrollView.backgroundColor = [UIColor blackColor];
            self.contentView.backgroundColor = [UIColor blackColor];
            break;
        case WBImagePickerStyleLight:
            self.myScrollView.backgroundColor = kLightStyleBGColor;
            self.contentView.backgroundColor = kLightStyleBGColor;
            break;
        default:
            break;
    }
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mp_singleTap:)];
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mp_doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];
}

- (void)mp_resizeSubviews {
    if (!_isLivePhoto) {
        self.imageView.WB_origin = CGPointZero;
        self.imageView.WB_width = self.myScrollView.WB_width;
        
        UIImage *image = self.imageView.image;
        if (image.size.height / image.size.width > self.WB_height / self.myScrollView.WB_width) {
            _imageView.WB_height = floor(image.size.height / (image.size.width / self.myScrollView.WB_width));
        } else {
            CGFloat height = image.size.height / image.size.width * self.myScrollView.WB_width;
            if (height < 1 || isnan(height)) height = self.WB_height;
            height = floor(height);
            _imageView.WB_height = height;
            _imageView.WB_centerY = self.WB_height / 2;
        }
        
        if (_imageView.WB_height > self.WB_height && _imageView.WB_height - self.WB_height <= 1) {
            _imageView.WB_height = self.WB_height;
        }
        
        _myScrollView.contentSize = CGSizeMake(_myScrollView.WB_width, MAX(_imageView.WB_height, self.WB_height));
        [_myScrollView scrollRectToVisible:self.bounds animated:NO];
        _myScrollView.alwaysBounceVertical = _imageView.WB_height <= self.WB_height ? NO : YES;
    } else {
        self.livePhotoView.WB_origin = CGPointZero;
        self.livePhotoView.WB_width = self.myScrollView.WB_width;
        
        PHLivePhoto *photo = self.livePhotoView.livePhoto;
        if (photo.size.height / photo.size.width > self.WB_height / self.myScrollView.WB_width) {
            _livePhotoView.WB_height = floor(photo.size.height / (photo.size.width / self.myScrollView.WB_width));
        } else {
            CGFloat height = photo.size.height / photo.size.width * self.myScrollView.WB_width;
            if (height < 1 || isnan(height)) height = self.WB_height;
            height = floor(height);
            _livePhotoView.WB_height = height;
            _livePhotoView.WB_centerY = self.WB_height / 2;
        }
        
        if (_livePhotoView.WB_height > self.WB_height && _livePhotoView.WB_height - self.WB_height <= 1) {
            _livePhotoView.WB_height = self.WB_height;
        }
        
        _myScrollView.contentSize = CGSizeMake(_myScrollView.WB_width, MAX(_livePhotoView.WB_height, self.WB_height));
        [_myScrollView scrollRectToVisible:self.bounds animated:NO];
        _myScrollView.alwaysBounceHorizontal = _livePhotoView.WB_height <= self.WB_height ? NO : YES;
    }
}

- (void)mp_singleTap:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(photoHasBeenTapped)]) {
        [_delegate photoHasBeenTapped];
    }
}

- (void)mp_doubleTap:(UITapGestureRecognizer *)gesture {
    if (self.myScrollView.zoomScale > 1.f) {
        [_myScrollView setZoomScale:1.f animated:YES];
    } else {
        CGPoint touchPoint = [gesture locationInView:self.imageView];
        CGFloat newZoomScale = _myScrollView.maximumZoomScale;
        CGFloat xSize = self.frame.size.width / newZoomScale;
        CGFloat ySize = self.frame.size.height / newZoomScale;
        [_myScrollView zoomToRect:CGRectMake(touchPoint.x - xSize/2, touchPoint.y - ySize/2, xSize, ySize) animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
// 让UIImageView在UIScrollView缩放后居中显示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    if (!_isLivePhoto) {
        self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    } else {
        self.livePhotoView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (_isLivePhoto) {
        return self.livePhotoView;
    }
    return self.imageView;
}
@end
