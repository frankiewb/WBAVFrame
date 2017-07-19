//
//  WBAACEncoder.h
//  WBCodec
//
//  Created by 王博 on 2017/6/28.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "WBAudioFrame.h"


@protocol WBAACEncoderDelegate <NSObject>

//硬编码后得到的每一个帧数据
- (void)wbAACEncoderDidFinishEncodeWithWBAudioFrame:(WBAudioFrame *)audioFrame;

@end

@interface WBAACEncoder : NSObject

@property (nonatomic, assign) id<WBAACEncoderDelegate> delegate;

- (void)encodeWithSampleBuffer:(CMSampleBufferRef )sampleBuffer timeStamp:(uint64_t)timeStamp;

@end
