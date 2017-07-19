//
//  WBVideoFrame.h
//  WBCodec
//
//  Created by 王博 on 2017/7/4.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBVideoFrame : NSObject

@property (nonatomic, assign) BOOL isKeyFrame;//该帧是否为关键帧

@property (nonatomic, strong) NSData *spsData;

@property (nonatomic, strong) NSData *ppsData;

@property (nonatomic, assign) uint64_t timeStamp;

@property (nonatomic, strong) NSData *frameData;

@property (nonatomic, strong) NSData *videoFrameHeader;

@end
