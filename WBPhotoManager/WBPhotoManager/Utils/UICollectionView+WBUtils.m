//
//  UICollectionView+Utils.m
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/14.
//  Copyright © 2016年 王博. All rights reserved.
//

#import "UICollectionView+WBUtils.h"

@implementation UICollectionView (WBUtils)

- (NSArray *)indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    
    if (allLayoutAttributes.count == 0) return nil;
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    
    return indexPaths;
}

@end
