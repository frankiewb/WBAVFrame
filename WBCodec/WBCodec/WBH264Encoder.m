//
//  WBH264Encoder.m
//  WBCodec
//
//  Created by 王博 on 2017/6/28.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBH264Encoder.h"


@interface WBH264Encoder ()

@property (nonatomic, assign) VTCompressionSessionRef videoEncodeSession;//当前编码session

@property (nonatomic, assign) NSInteger videoFrameCount;//当前帧数

@property (nonatomic, assign) NSInteger videoFps;//设置的帧率

@property (nonatomic, assign) NSInteger videoBitRate;//设置的比特率

@property (nonatomic, assign) CGSize videoSize;//视频大小

@property (nonatomic, strong) dispatch_queue_t videoEncodeQueue;//视频编码处理队列

@property (nonatomic, strong) NSData *videoSPS;//H264 SPS头

@property (nonatomic, strong) NSData *videoPPS;//H264 PPS头

@end



@implementation WBH264Encoder


- (instancetype)init
{
    if (self = [super init])
    {
        [self setEncodeSessionSettingData];
        [self initEncodeSession];
    }
    
    return self;
}

- (void)dealloc
{
    [self destroyEncodeSession];
}


- (void)setEncodeSessionSettingData
{
    // 设置视频的宽高, 宽高必须给 2 的倍数, 不然会出现蓝边
    // framerate 设置帧率 级fps
    // 设置比特率
    
    /**
     // 分辨率： 368 *640 帧数：15 码率：500Kps
     // 分辨率： 368 *640 帧数：24 码率：800Kps
     // 分辨率： 368 *640 帧数：30 码率：800Kps
     // 分辨率： 540 *960 帧数：15 码率：800Kps
     // 分辨率： 540 *960 帧数：24 码率：800Kps
     // 分辨率： 540 *960 帧数：30 码率：800Kps
     // 分辨率： 720 *1280 帧数：15 码率：1000Kps
     // 分辨率： 720 *1280 帧数：24 码率：1200Kps
     // 分辨率： 720 *1280 帧数：30 码率：1200Kps
     */
    
    self.videoEncodeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.videoSize = CGSizeMake(720, 1280);
    self.videoFps = 24;
    self.videoBitRate = 1600 * 1000;
}

- (void)initEncodeSession
{
    if (self.videoEncodeSession)
    {
        VTCompressionSessionCompleteFrames(_videoEncodeSession, kCMTimeInvalid);
        VTCompressionSessionInvalidate(_videoEncodeSession);
        CFRelease(_videoEncodeSession);
        self.videoEncodeSession = NULL;
    }
    
    OSStatus compressStatus;
    self.videoFrameCount = 0;
    
    //创建硬编码器
    compressStatus = VTCompressionSessionCreate(kCFAllocatorDefault, _videoSize.width, _videoSize.height, kCMVideoCodecType_H264, NULL, NULL, NULL, VideoCompressonOutputCallback, (__bridge void *)(self), &_videoEncodeSession);
    
    if (compressStatus != noErr)
    {
        NSLog(@"VTCompressionSessionCreate failed. ret=%d", compressStatus);
        return;
    }
    
    //设置硬编码器参数
    //1. 设置GOP Size,关键帧间隔，表明每2秒共2*videoFps帧中一个关键帧
    compressStatus = VTSessionSetProperty(_videoEncodeSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, (__bridge CFTypeRef)@(_videoFps *2));
    //2. 暂时没必要设置
    compressStatus = VTSessionSetProperty(_videoEncodeSession, kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, (__bridge CFTypeRef)@(_videoFps*2));
    //3. 设置帧率，只用于初始化用，参考意义，实际帧率变化依赖于诸多设置
    compressStatus = VTSessionSetProperty(_videoEncodeSession, kVTCompressionPropertyKey_ExpectedFrameRate, (__bridge CFTypeRef)@(_videoFps));
    //4. 设置码率
    compressStatus  = VTSessionSetProperty(_videoEncodeSession, kVTCompressionPropertyKey_AverageBitRate, (__bridge CFTypeRef)@(_videoBitRate));
    //5. 设置速率限制
    NSArray *videoBitRateLimit = @[@(_videoBitRate * 1.5/8),@(1)];
    compressStatus = VTSessionSetProperty(_videoEncodeSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)videoBitRateLimit);
    //6. 设置实时编码输出，降低编码延迟
    compressStatus = VTSessionSetProperty(_videoEncodeSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
    //7. H264 Profile，选用H264_High_5_2
    compressStatus = VTSessionSetProperty(_videoEncodeSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_High_5_2);
    //8. 防止B帧被自动重新排序
    compressStatus = VTSessionSetProperty(_videoEncodeSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
    //9. 设置H264 熵编码模式 H264标准采用了两种熵编码模式，熵编码即编码过程中按熵原理不丢失任何信息的编码。信息熵为信源的平均信息量（不确定性的度量）
    compressStatus = VTSessionSetProperty(_videoEncodeSession, kVTCompressionPropertyKey_H264EntropyMode, kVTH264EntropyMode_CABAC);
    
    
    //开始编码
    compressStatus = VTCompressionSessionPrepareToEncodeFrames(_videoEncodeSession);
    NSLog(@"start encode  return: %d", compressStatus);
    
}


// 编码一帧图像，使用queue，防止阻塞系统摄像头采集线程

- (void)encodeWithSampleBuffer:(CMSampleBufferRef)sampleBuffer timeStamp:(uint64_t)timeStamp
{
    dispatch_sync(_videoEncodeQueue, ^{
        
        CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        self.videoFrameCount ++;
        CMTime pts = CMTimeMake(_videoFrameCount, 1000);
        CMTime duration = kCMTimeInvalid;
        NSDictionary *properties = nil;
        
        //关键帧的最大间隔设为帧率的二倍
        if (self.videoFrameCount % self.videoFps * 2 == 0)
        {
            properties = @{(__bridge NSString *)kVTEncodeFrameOptionKey_ForceKeyFrame: @YES};
        }
        
        NSNumber *timeNumber = @(timeStamp);
        VTEncodeInfoFlags encodeFlags;
        
        //送入编码器编码
        OSStatus encodeStatusCode = VTCompressionSessionEncodeFrame(_videoEncodeSession, imageBuffer, pts, duration, (__bridge CFDictionaryRef)properties, (__bridge_retained void *)timeNumber, &encodeFlags);
        
        if (encodeStatusCode != noErr)
        {
            NSLog(@"H264: VTCompressionSessionEncodeFrame failed with %d", encodeStatusCode);
            [self destroyEncodeSession];
            return ;
        }
    });
}


// 编码回调, 系统每完成一帧编码后, 就会异步调用该方法, 该方法为c 语言
static void VideoCompressonOutputCallback(void *userData, void *sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer)
{
    
    if (!sampleBuffer) return;
    CFArrayRef sampleAttachmentsArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true);
    if (!sampleAttachmentsArray) return;
    CFDictionaryRef valueDic = (CFDictionaryRef)CFArrayGetValueAtIndex(sampleAttachmentsArray, 0);
    if (!valueDic) return;
    
    uint64_t timeStamp = [((__bridge_transfer NSNumber*)sourceFrameRefCon) longLongValue];
    WBH264Encoder *wbVideoEncoder = (__bridge WBH264Encoder *)userData;
    if (status != noErr) return;
    
    // 判断当前帧是否为关键帧
    BOOL isKeyFrame = CFDictionaryContainsKey(valueDic, kCMSampleAttachmentKey_NotSync);
    
    // 获取 sps pps 数据, sps pps 只需要获取一次, 保存在h.264文件开头即可
    // SPS 对于H264而言，就是编码后的第一帧，如果是读取的H264文件，就是第一个帧界定符和第二个帧界定符之间的数据的长度是4
    // PPS 就是编码后的第二帧，如果是读取的H264文件，就是第二帧界定符和第三帧界定符中间的数据长度不固定。
    // 在每一个帧中都将保留SPS，PPS这样做的目的是为了解码时非关键帧能够在关键帧丢失的情况下仍然依靠本身携带的sps，pps进行解码还原-WB
    
    //使用RTP传输H264的时候,需要用到sdp协议描述,其中有两项:Sequence Parameter Sets (SPS) 和Picture Parameter Set (PPS)需要用到,那么这两项从哪里获取呢?答案是从H264码流中获取.在H264码流中,都是以"0x00 0x00 0x01"或者"0x00 0x00 0x00 0x01"为开始码的,找到开始码之后,使用开始码之后的第一个字节的低5位判断是否为7(sps)或者8(pps), 及data[4] & 0x1f == 7 || data[4] & 0x1f == 8.然后对获取的nal去掉开始码之后进行base64编码,得到的信息就可以用于sdp.sps和pps需要用逗号分隔开来.
    
    //1.提取关键帧的SPS，PPS
    if (isKeyFrame && !wbVideoEncoder.videoSPS && !wbVideoEncoder.videoPPS)
    {
        size_t spsSize, spsCount;
        size_t ppsSize, ppsCount;
        
        const uint8_t *spsData, *ppsData;
        CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
        OSStatus err0 = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDesc, 0, &spsData, &spsSize, &spsCount, 0 );
        OSStatus err1 = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDesc, 1, &ppsData, &ppsSize, &ppsCount, 0 );
        
        if (err0 == noErr && err1 == noErr)
        {
            wbVideoEncoder.videoSPS = [NSData dataWithBytes:spsData length:spsSize];
            wbVideoEncoder.videoPPS = [NSData dataWithBytes:ppsData length:ppsSize];
        }
    }
    
    //2.封装WBVideoFrame
    size_t lengthAtOffset, totalLength;
    char *data;
    
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    OSStatus error = CMBlockBufferGetDataPointer(dataBuffer, 0, &lengthAtOffset, &totalLength, &data);
    if (error == noErr) {
        size_t offset = 0;
        const int lengthInfoSize = 4; // 返回的nalu数据前四个字节不是0001的startcode，而是大端模式的帧长度length
        
        // 循环获取nalu数据
        while (offset < totalLength - lengthInfoSize) {
            uint32_t naluLength = 0;
            memcpy(&naluLength, data + offset, lengthInfoSize); // 获取nalu的长度，
            
            // 大端模式转化为系统端模式
            naluLength = CFSwapInt32BigToHost(naluLength);
            
            WBVideoFrame *videoFrame = [[WBVideoFrame alloc] init];
            videoFrame.timeStamp = timeStamp;
            videoFrame.frameData = [[NSData alloc] initWithBytes:(data + offset + lengthInfoSize) length:naluLength];
            videoFrame.isKeyFrame = isKeyFrame;
            videoFrame.spsData = wbVideoEncoder.videoSPS;
            videoFrame.ppsData = wbVideoEncoder.videoPPS;
            if (wbVideoEncoder.delegate && [wbVideoEncoder.delegate respondsToSelector:@selector(wbH264EncoderDidFinishEncodeWithWBVideoFrame:)])
            {
                [wbVideoEncoder.delegate wbH264EncoderDidFinishEncodeWithWBVideoFrame:videoFrame];
            }
            // 读取下一个nalu，一次回调可能包含多个nalu
            offset += lengthInfoSize + naluLength;
        }
    }
   
}

- (void)destroyEncodeSession
{
    if (self.videoEncodeSession)
    {
        VTCompressionSessionCompleteFrames(_videoEncodeSession, kCMTimeInvalid);
        VTCompressionSessionInvalidate(_videoEncodeSession);
        CFRelease(_videoEncodeSession);
        _videoEncodeSession = NULL;
    }
}









@end
