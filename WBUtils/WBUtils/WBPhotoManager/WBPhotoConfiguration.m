//
//  WBPhotoConfiguration.m
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/13.
//  Copyright © 2016年 王博. All rights reserved.
//

#import "WBPhotoConfiguration.h"

@implementation WBPhotoConfiguration

+ (instancetype)defaultConfiguration {
    static WBPhotoConfiguration *config = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[WBPhotoConfiguration alloc] init];
        
        config.mutiSelected = YES;
        config.maxSelectCount = 9;
        config.maxImageWidth = 1280;
        config.numsInRow = 4;
        config.masking = YES;
        config.selectedAnimation = YES;
        config.themeStyle = WBImagePickerStyleDark;
        config.photoMomentGroupType = WBImageMomentGroupTypeNone;
        config.photosDesc = YES;
        config.showAlbumThumbnail = YES;
        config.showAlbumNumber = YES;
        config.showEmptyAlbum = NO;
        config.onlyShowImages = NO;
        config.showLivePhotoIcon = YES;
        config.callBackLivePhoto = YES;
        config.firstCamera = YES;
        config.dynamicCamera = NO;
        config.makingVideo = YES;
        config.videoAutoSave = YES;
        config.videoMaximumDuration = 60.f;
        config.pickGIF = YES;
        
        config.gridPadding = 4;
    });
    
    return config;
}

- (CGFloat)gridWidth {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    return (screenSize.width-4) / (CGFloat)self.numsInRow - self.gridPadding;
}

@end
