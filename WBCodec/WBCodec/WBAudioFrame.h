//
//  WBAudioFrame.h
//  WBCodec
//
//  Created by 王博 on 2017/7/4.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBAudioFrame : NSObject

@property (nonatomic, strong) NSData *audioFrameHeader;

@property (nonatomic, strong) NSData *frameData;

@property (nonatomic, assign) uint64_t timeStamp;

@end
