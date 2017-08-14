//
//  WBNativeVideoWriter.h
//  WBAVNAtiveRecorder
//
//  Created by 王博 on 2017/8/10.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>


//视频本地写入器状态
typedef NS_ENUM(NSInteger,WBNativeVideoWriterType)
{
    WBNativeVideoWriterTypeNone = 0,
    WBNativeVideoWriterTypeReady,
    WBNativeVideoWriterTypeWriting,
    WBNativeVideoWriterTypeComplete,
    WBNativeVideoWriterTypeStop,
    WBNativeVideoWriterTypeError,
};

//录制本地视频长宽比
typedef NS_ENUM(NSInteger,WBNativeVideoAspectRatioType)
{
    WBNativeVideoAspectRatioType1x1 = 0, //长宽比1:1
    WBNativeVideoAspectRatioType4X3,//长宽比4:3
    WBNativeVideoAspectRatioType16x9,//长宽比16:9
    WBNativeVideoAspectRatioTypeFullScreen,//依据当前采集设备屏幕比例全屏
};

@class WBNativeVideoWriter;

@protocol WBNativeVideoWtiterDelegate <NSObject>

//视频本地写入器状态代理
- (void)videoWriterStatus:(WBNativeVideoWriter *)videoWriter status:(WBNativeVideoWriterType)status;

@end

@interface WBNativeVideoWriter : NSObject

@property (nonatomic,weak) id<WBNativeVideoWtiterDelegate> delegate;

- (instancetype)initWithVideoStoreURL:(NSString *)Url VideoAspectRationType:(WBNativeVideoAspectRatioType)aspectRationType;

//开始录播写入器
- (void)startWriter;

//停止录播写入器
- (void)stopWriter;

//销毁录播写入器
- (void)destroyWriter;

//将sampleBuffer压缩编码并写入对应的URL地址
- (void)writeWithSampleBuffer:(CMSampleBufferRef)sampleBuffer MediaType:(NSString *)mediaType;


@end
