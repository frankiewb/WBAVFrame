//
//  WBMoment.h
//  WBUtils
//
//  Created by 王博 on 2017/8/16.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WBAssetModel;

@interface WBMoment : NSObject

@property (strong, nonatomic) NSDateComponents *dateComponents;

@property (strong, nonatomic) NSDate *date;

@property (assign, nonatomic) WBImageMomentGroupType groupType;

@property (strong, nonatomic) NSMutableArray <WBAssetModel *>*assets;

@end
