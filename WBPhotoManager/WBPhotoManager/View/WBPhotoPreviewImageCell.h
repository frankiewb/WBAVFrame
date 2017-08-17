//
//  WBPhotoPreviewCell.h
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/19.
//  Copyright © 2016年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBPhotoPreviewCellDelegate.h"

#define kLightStyleBGColor [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.00]

@class WBAssetModel;
@interface WBPhotoPreviewImageCell : UICollectionViewCell

@property (strong, nonatomic) WBAssetModel *model;

@property (weak, nonatomic) id<WBPhotoPreviewCellDelegate> delegate;

/**
 已经显示到了那个cell
 */
- (void)didDisplayed;

- (void)recoverSubviews;

@end
