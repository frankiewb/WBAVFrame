//
//  WBVideoFrame.h
//  WBCodec
//
//  Created by 王博 on 2017/7/4.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBFrame.h"

@interface WBVideoFrame : WBFrame

@property (nonatomic, assign) BOOL isKeyFrame;//该帧是否为关键帧

@property (nonatomic, strong) NSData *spsData;

@property (nonatomic, strong) NSData *ppsData;

@end
