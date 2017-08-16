//
//  WBMoment.m
//  WBUtils
//
//  Created by 王博 on 2017/8/16.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBMoment.h"

@implementation WBMoment

- (NSMutableArray <WBAssetModel *>*)assets
{
    if (!_assets) {
        self.assets = [NSMutableArray array];
    }
    return _assets;
}

@end
