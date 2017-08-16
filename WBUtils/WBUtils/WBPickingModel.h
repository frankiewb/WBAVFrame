//
//  WBPickingModel.h
//  WBUtils
//
//  Created by 王博 on 2017/8/16.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WBAssetBaseModel.h"


@interface WBPickingModel : WBAssetBaseModel

@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) PHLivePhoto *livePhoto;

@property (strong, nonatomic) NSURL *videoURL;

@end
