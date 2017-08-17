//
//  WBPhtoGridBaseCell.m
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/17.
//  Copyright © 2016年 王博. All rights reserved.
//

#import "WBPhotoGridCell.h"
#import <PhotosUI/PHLivePhotoView.h>
#import "WBPhotoConfiguration.h"
#import "WBPhotoManager.h"
#import "UIView+WBUtils.h"
#import "WBAssetModel.h"
#import "WBCameraView.h"

@interface WBPhotoGridCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *liveBadgeImageView;
@property (strong, nonatomic) UIImageView *videoLengthBgView;
@property (strong, nonatomic) UIImageView *videoBadgeImageView;
@property (strong, nonatomic) UILabel *videoLengthLabel;

@property (strong, nonatomic) UIButton *selectButton;
@property (strong, nonatomic) UIImageView *maskingImageView;
@end

@implementation WBPhotoGridCell
#pragma mark - Initialization Method
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self imageView];
    }
    return self;
}

#pragma mark - Instance Methods
- (void)mp_selectButtonDidSelected:(UIButton *)sender {
    WBPhotoConfiguration *config = [WBPhotoConfiguration defaultConfiguration];
    BOOL selected = NO;
    
    if ([self.delegate respondsToSelector:@selector(gridCellSelectedButtonDidClicked:selectedAsset:)])
        selected = [self.delegate gridCellSelectedButtonDidClicked:!sender.isSelected selectedAsset:_asset];
    
    sender.selected = selected;
    if (selected) {
        if (config.allowsSelectedAnimation)
            [sender addSpringAnimation];
        if (config.allowsMasking)
            self.maskingImageView.hidden = NO;
    } else {
        if (config.allowsMasking)
            self.maskingImageView.hidden = YES;
    }
}

#pragma mark - Setter
- (void)setAsset:(WBAssetModel *)asset {
    _asset = asset;
    
    [[WBPhotoManager defaultManager] getThumbnailImageFromPHAsset:asset.asset photoWidth:self.contentView.WB_width completionBlock:^(UIImage *result, NSDictionary *info) {
        self.imageView.image = result;
    }];
    WBPhotoConfiguration *config = [WBPhotoConfiguration defaultConfiguration];
    
    self.videoLengthBgView.hidden = YES;
    if (config.allowsMasking) self.maskingImageView.hidden = YES;
    self.selectButton.hidden = YES;
    self.liveBadgeImageView.hidden = YES;
    self.videoLengthLabel.text = @"";
    
    if (asset.type == WBAssetModelMediaTypeVideo) {
        //视频
        self.videoLengthBgView.hidden = NO;
        self.videoLengthLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)asset.videoDuration/60, (int)asset.videoDuration%60];
    } else if (asset.type == WBAssetModelMediaTypeLivePhoto && config.isShowLivePhotoIcon) {
        //Live 图片
        self.liveBadgeImageView.hidden = NO;
        self.selectButton.hidden = NO;
    } else {
        self.selectButton.hidden = NO;
    }
    self.selectButton.selected = asset.isSelected;
    if (asset.isSelected && config.allowsMasking)
        self.maskingImageView.hidden = NO;
}

#pragma mark - Lazy Load
- (UIImageView *)imageView {
    if (!_imageView) {
        self.imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_imageView];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.contentView addConstraints:@[top, leading, trailing, bottom]];
    }
    return _imageView;
}

- (UIImageView *)videoLengthBgView {
    if (!_videoLengthBgView) {
        self.videoLengthBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_grid_videoLength"]];
        _videoLengthBgView.contentMode = UIViewContentModeScaleToFill;
        _videoLengthBgView.clipsToBounds = YES;
        _videoLengthBgView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_videoLengthBgView];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_videoLengthBgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-24];
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_videoLengthBgView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_videoLengthBgView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_videoLengthBgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.contentView addConstraints:@[top, leading, trailing, bottom]];
    }
    return _videoLengthBgView;
}

- (UILabel *)videoLengthLabel {
    if (!_videoLengthLabel) {
        self.videoLengthLabel = [UILabel new];
        _videoLengthLabel.font = [UIFont systemFontOfSize:11];
        _videoLengthLabel.textColor = [UIColor whiteColor];
        _videoLengthLabel.textAlignment = NSTextAlignmentRight;
        _videoLengthLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.videoLengthBgView addSubview:_videoLengthLabel];
        
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_videoLengthLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.videoLengthBgView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-5];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_videoLengthLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.videoLengthBgView attribute:NSLayoutAttributeCenterY multiplier:1 constant:3];
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_videoLengthLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.videoBadgeImageView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        [self.videoLengthBgView addConstraints:@[trailing, centerY, leading]];
    }
    return _videoLengthLabel;
}

- (UIImageView *)videoBadgeImageView {
    if (!_videoBadgeImageView) {
        self.videoBadgeImageView = [UIImageView new];
        _videoBadgeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _videoBadgeImageView.clipsToBounds = YES;
        _videoBadgeImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _videoBadgeImageView.image = [UIImage imageNamed:@"icon_grid_video_badge"];
        
        [self.videoLengthBgView addSubview:_videoBadgeImageView];
        
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_videoBadgeImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.videoLengthBgView attribute:NSLayoutAttributeLeading multiplier:1 constant:3.f];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_videoBadgeImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:15];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_videoBadgeImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:20];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_videoBadgeImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.videoLengthBgView attribute:NSLayoutAttributeCenterY multiplier:1 constant:3];
        [self.videoLengthBgView addConstraints:@[leading, height, centerY, width]];
    }
    return _videoBadgeImageView;
}

- (UIImageView *)liveBadgeImageView {
    if (!_liveBadgeImageView) {
        self.liveBadgeImageView = [[UIImageView alloc] initWithImage:[PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent]];
        _liveBadgeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _liveBadgeImageView.clipsToBounds = YES;
        _liveBadgeImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_liveBadgeImageView];
        
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:30];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_liveBadgeImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:30];
        [self.contentView addConstraints:@[leading, top, width, height]];
    }
    return _liveBadgeImageView;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        self.selectButton = [UIButton new];
        _selectButton.translatesAutoresizingMaskIntoConstraints = NO;
        WBPhotoConfiguration *config = [WBPhotoConfiguration defaultConfiguration];
        [_selectButton setImage:config.photoNormal ? config.photoNormal : [UIImage imageNamed:@"icon_picture_normal"] forState:UIControlStateNormal];
        [_selectButton setImage:config.photoSelected ? config.photoSelected : [UIImage imageNamed:@"icon_picture_selected"] forState:UIControlStateSelected];
        [_selectButton setImageEdgeInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        
        [_selectButton addTarget:self action:@selector(mp_selectButtonDidSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_selectButton];
        
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_selectButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_selectButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_selectButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-self.frame.size.width/3.f];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_selectButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_selectButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        
        [self.contentView addConstraints:@[trailing, top, width, height]];
    }
    return _selectButton;
}

- (UIImageView *)maskingImageView {
    if (!_maskingImageView) {
        self.maskingImageView = [UIImageView new];
        _maskingImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_maskingImageView];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_maskingImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_maskingImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_maskingImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_maskingImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.contentView addConstraints:@[top, leading, trailing, bottom]];
        
        WBPhotoConfiguration *config = [WBPhotoConfiguration defaultConfiguration];
        switch (config.themeStyle) {
            case WBImagePickerStyleDark:
                _maskingImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
                break;
            case WBImagePickerStyleLight:
                _maskingImageView.backgroundColor = [UIColor colorWithWhite:1 alpha:.3];
                break;
        }
    }
    return _maskingImageView;
}
@end



@interface WBPhotoGridCameraCell ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation WBPhotoGridCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView.image = [UIImage imageNamed:@"icon_album_camera"];
        if ([WBPhotoConfiguration defaultConfiguration].dynamicCamera)
            [self.cameraView startSession];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        self.imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:_imageView];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.contentView addConstraints:@[top, leading, trailing, bottom]];
    }
    return _imageView;
}

- (WBCameraView *)cameraView {
    if (!_cameraView) {
        self.cameraView = [[WBCameraView alloc] init];
        _cameraView.translatesAutoresizingMaskIntoConstraints = NO;

        [_cameraView setPreviewLayerFrame:CGRectMake(0, 0, [WBPhotoConfiguration defaultConfiguration].gridWidth, [WBPhotoConfiguration defaultConfiguration].gridWidth)];
        
        [self.contentView addSubview:_cameraView];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_cameraView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_cameraView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_cameraView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_cameraView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.contentView addConstraints:@[top, leading, trailing, bottom]];
    }
    return _cameraView;
}

- (void)setCameraImage:(UIImage *)cameraImage {
    _cameraImage = cameraImage;
    
    self.imageView.image = cameraImage;
}

@end
