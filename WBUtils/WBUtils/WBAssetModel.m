//
//  WBAssetModel.m
//  WBUtils
//
//  Created by 王博 on 2017/8/16.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBAssetModel.h"

@implementation WBAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset
{
    WBAssetModel *model = [WBAssetModel new];
    
    model.asset = asset;
    
    return model;
}

- (NSString *)identifier
{
    return self.asset.localIdentifier;
}

- (WBAssetModelMediaType)type
{
    if (self.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) return WBAssetModelMediaTypeLivePhoto;
    
    if (self.asset.mediaType == PHAssetMediaTypeImage) return WBAssetModelMediaTypeImage;
    
    if (self.asset.mediaType == PHAssetMediaTypeVideo) return WBAssetModelMediaTypeVideo;
    
    if (self.asset.mediaType == PHAssetMediaTypeAudio) return WBAssetModelMediaTypeAudio;
    
    return WBAssetModelMediaTypeUnkown;
}

- (NSTimeInterval)videoDuration
{
    if (self.type == WBAssetModelMediaTypeVideo)
        return self.asset.duration;
    else
        return 0.f;
}

- (NSString *)description
{
    return self.debugDescription;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %p> identifier:%@ | type: %zi", [self class], self, self.identifier, self.type];
}

@end
