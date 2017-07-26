//
//  WBRtmpHandler.h
//  WBRtmpHandler
//
//  Created by 王博 on 2017/6/27.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBRtmpStreamInfo.h"



@class WBRtmpHandler;
@class WBFrame;

@protocol WBRtmpHandlerDelegate <NSObject>

- (void)socketStatus:(WBRtmpHandler *)rtmpHandler status:(WBLiveStateType)status;

@end

@interface WBRtmpHandler : NSObject

@property (nonatomic, weak) id<WBRtmpHandlerDelegate>delegate;

- (instancetype)initWithStreamInfo:(WBRtmpStreamInfo *)streamInfo;

- (void)start;

- (void)stop;

- (void)sendWBFrame:(WBFrame *)frame;//音频Frame或者是视频Frame;

@end
