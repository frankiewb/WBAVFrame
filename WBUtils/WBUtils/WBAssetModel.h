//
//  WBAssetModel.h
//  WBUtils
//
//  Created by 王博 on 2017/8/16.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "WBAssetBaseModel.h"

@interface WBAssetModel :WBAssetBaseModel

@property (strong, nonatomic) PHAsset *asset;

@property (assign, nonatomic, getter=isSelected) BOOL selected;

+ (instancetype)modelWithAsset:(PHAsset *)asset;

@end
