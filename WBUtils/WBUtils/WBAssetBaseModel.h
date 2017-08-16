//
//  WBAssetBaseModel.h
//  WBUtils
//
//  Created by WangBo on 2017/8/16.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WBAssetModelMediaType) {
    WBAssetModelMediaTypeImage,
    WBAssetModelMediaTypeLivePhoto,
    WBAssetModelMediaTypeGIF,
    WBAssetModelMediaTypeVideo,
    WBAssetModelMediaTypeAudio,
    WBAssetModelMediaTypeUnkown
};


@interface WBAssetBaseModel : NSObject

@property (copy, nonatomic) NSString *identifier;

@property (assign, nonatomic) WBAssetModelMediaType type;

//只有当 type 为 video 时有值
@property (assign, nonatomic) NSTimeInterval videoDuration;


@end
