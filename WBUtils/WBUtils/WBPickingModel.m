//
//  WBPickingModel.m
//  WBUtils
//
//  Created by 王博 on 2017/8/16.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBPickingModel.h"

@implementation WBPickingModel

- (NSString *)description
{
    return self.debugDescription;
}

- (NSString *)debugDescription
{
    id obj;
    if (self.image) obj = self.image;
    if (self.livePhoto) obj = self.livePhoto;
    if (self.videoURL) obj = self.videoURL;
    
    return [NSString stringWithFormat:@"<%@: %p> id: %@ | type: %zi | content: %@", [self class], self, self.identifier, self.type, obj];
}



@end
