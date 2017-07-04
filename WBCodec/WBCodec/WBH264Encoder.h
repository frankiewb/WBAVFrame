//
//  WBH264Encoder.h
//  WBCodec
//
//  Created by 王博 on 2017/6/28.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "WBVideoFrame.m"

@protocol WBH264EncoderDelegate <NSObject>

//硬编码后得到的每一个帧数据
- (void)wbH264EncoderDidFinishEncodeWithWBVideoFrame:(WBVideoFrame *)videoFrame;

@end


@interface WBH264Encoder : NSObject

@property (nonatomic, weak) NSObject<WBH264EncoderDelegate> *delegate;

- (void)encodeWithSampleBuffer:(CMSampleBufferRef )sampleBuffer timeStamp:(uint64_t)timeStamp;


@end
