//
//  WBAudioFrame.h
//  WBCodec
//
//  Created by 王博 on 2017/7/4.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBAudioFrame : NSObject

@property (nonatomic, assign) BOOL isKeyFrame;//是否是关键帧
@property (nonatomic, strong) NSData *sps;//Sequence Parameter Sets
@property (nonatomic, strong) NSData *pps;//Picture Parameter Set

@end
