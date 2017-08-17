//
//  NSIndexSet+Utils.m
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/14.
//  Copyright © 2016年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSIndexSet+WBUtils.h"

@implementation NSIndexSet (WBUtils)

- (NSArray *)indexPathsFromIndexesWithSection:(NSUInteger)section isShowCamera:(BOOL)isShowCamera {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (isShowCamera) idx++;
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    
    return indexPaths;
}

@end
