//
//  WBAlbumModel.m
//  WBUtils
//
//  Created by 王博 on 2017/8/16.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBAlbumModel.h"

@implementation WBAlbumModel

- (NSUInteger)count
{
    return self.models.count;
}

- (NSString *)description
{
    return self.debugDescription;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %p> albumName:%@ | count:%zi", [self class], self, self.albumName, self.count];
}

- (void)setContent:(PHFetchResult *)content {
    _content = content;
    
    [[WBPhotoManager defaultManager] getWBAssetModelWithPHFetchResult:content completionBlock:^(NSArray<WBAssetModel *> *models)
    {
        self.models = models;
    }];
}

@end
