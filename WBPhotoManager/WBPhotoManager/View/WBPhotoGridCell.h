//
//  WBPhtoGridBaseCell.h
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/17.
//  Copyright © 2016年 王博. All rights reserved.
//

#import <Photos/Photos.h>

@class WBAssetModel, WBCameraView;

@protocol WBPhotoGridCellDelegate <NSObject>

- (BOOL)gridCellSelectedButtonDidClicked:(BOOL)isSelected selectedAsset:(WBAssetModel *)asset;

@end

@interface WBPhotoGridCell : UICollectionViewCell

@property (strong, nonatomic) WBAssetModel *asset;
@property (weak, nonatomic) id<WBPhotoGridCellDelegate> delegate;

@end




@interface WBPhotoGridCameraCell : UICollectionViewCell

@property (strong, nonatomic) UIImage *cameraImage;

@property (strong, nonatomic) WBCameraView *cameraView;

@end
