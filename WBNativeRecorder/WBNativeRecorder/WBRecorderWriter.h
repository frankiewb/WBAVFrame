//
//  WBNativeVideoWriter.h
//  WBAVNAtiveRecorder
//
//  Created by 王博 on 2017/8/10.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>


//视频本地写入器状态
typedef NS_ENUM(NSInteger,WBRecorderWriterType)
{
    WBRecorderWriterTypeNone = 0,
    WBRecorderWriterTypeReady,
    WBRecorderWriterTypeWriting,
    WBRecorderWriterTypeComplete,
    WBRecorderWriterTypeStop,
    WBRecorderWriterTypeError,
};

//录制本地视频长宽比
typedef NS_ENUM(NSInteger,WBRecorderTypeAspectRatioType)
{
    WBRecorderTypeAspectRatioType1x1 = 0, //长宽比1:1
    WBRecorderTypeAspectRatioType4X3,//长宽比4:3
    WBRecorderTypeAspectRatioType16x9,//长宽比16:9
    WBRecorderTypeAspectRatioTypeFullScreen,//依据当前采集设备屏幕比例全屏
};

@class WBRecorderWriter;

@protocol WBRecorderWtiterDelegate <NSObject>

//视频本地写入器状态代理
- (void)recorderWriterStatus:(WBRecorderWriter *)recorderWriter status:(WBRecorderWriterType)status;

@end

@interface WBRecorderWriter : NSObject

@property (nonatomic,weak) id<WBRecorderWtiterDelegate> delegate;

- (instancetype)initWithVideoStoreURL:(NSString *)Url VideoAspectRationType:(WBRecorderTypeAspectRatioType)aspectRationType;

//开始录播写入器
- (void)startWriter;

//停止录播写入器
- (void)stopWriter;

//销毁录播写入器
- (void)destroyWriter;

//将sampleBuffer压缩编码并写入对应的URL地址
- (void)writeWithSampleBuffer:(CMSampleBufferRef)sampleBuffer MediaType:(NSString *)mediaType;


@end
