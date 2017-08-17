//
//  NSIndexSet+Utils.h
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/14.
//  Copyright © 2016年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexSet (WBUtils)

- (NSArray *)indexPathsFromIndexesWithSection:(NSUInteger)section isShowCamera:(BOOL)isShowCamera;;

@end
