//
//  WBPhotoPreviewController.h
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/19.
//  Copyright © 2016年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WBPhotoPreviewControllerDelegate <NSObject>

- (void)photoPreviewDisappearIsFullImage:(BOOL)isFullImage;

@end

@class WBAlbumModel, WBMoment;
@interface WBPhotoPreviewController : UIViewController

@property (weak, nonatomic) id<WBPhotoPreviewControllerDelegate> delegate;

/**
 配置 preview 界面

 @param album     具体的相册信息   specific album information
 @param item      选中的位置       where didSelected
 */
- (void)didSelectedWithAlbum:(WBAlbumModel *)album item:(NSInteger)item;

@end
