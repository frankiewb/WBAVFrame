//
//  WBPhotoGridController.h
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/9.
//  Copyright © 2016年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WBAlbumModel;

@interface WBPhotoGridController : UICollectionViewController

/**
 相册信息, album information
 */
@property (strong, nonatomic) WBAlbumModel *album;

/**
 添加 flowLayout

 @param num 一行有几个cell, the number of cells in one line

 */
+ (UICollectionViewFlowLayout *)flowLayoutWithNumInALine:(int)num;

@end
