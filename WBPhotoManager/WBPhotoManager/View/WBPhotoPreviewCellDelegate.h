//
//  WBPhotoPreviewCellDelegate.h
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/19.
//  Copyright © 2016年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WBPhotoPreviewCellDelegate <NSObject>

@optional

/**
 图片被点击一次
 */
- (void)photoHasBeenTapped;

@end
