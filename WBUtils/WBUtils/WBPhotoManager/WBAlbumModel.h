//
//  WBAlbumModel.h
//  WBUtils
//
//  Created by 王博 on 2017/8/16.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface WBAlbumModel : NSObject

/**
 相册名
 */
@property (copy  , nonatomic) NSString *albumName;

/**
 是否是『相机胶卷』
 */
@property (assign, nonatomic) BOOL isCameraRoll;

/**
 图片个数
 */
@property (assign, nonatomic, readonly) NSUInteger count;

/**
 相册内容
 */
@property (strong, nonatomic) PHFetchResult *content;

@property (strong, nonatomic) NSArray <WBAssetModel *>*models;

@end
