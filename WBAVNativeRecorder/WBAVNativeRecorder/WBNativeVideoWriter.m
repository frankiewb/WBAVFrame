//
//  WBNativeVideoWriter.m
//  WBAVNAtiveRecorder
//
//  Created by 王博 on 2017/8/10.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBNativeVideoWriter.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface WBNativeVideoWriter ()

//写入器状态
@property (nonatomic, assign) WBNativeVideoWriterType writerStatus;
//指定写入长宽比类型
@property (nonatomic, assign) WBNativeVideoAspectRatioType videoAspectRatioType;
//写入器实例
@property (nonatomic, strong) AVAssetWriter *recordWriter;
//指定写入视频SIZE
@property (nonatomic, assign) CGSize videoOutPutSize;
//写入URL地址
@property (nonatomic, strong) NSURL *videoURL;
//写入器工作队列
@property (nonatomic, strong) dispatch_queue_t writerWorkingQueue;
//写入器视频输入
@property (nonatomic, strong) AVAssetWriterInput *writerVideoInput;
//写入器音频输入
@property (nonatomic, strong) AVAssetWriterInput *writerAudioInput;
//视频压缩设置集合
@property (nonatomic, strong) NSDictionary *videoCompressionSettings;
//音频压缩设置集合
@property (nonatomic, strong) NSDictionary *audioCompressionSettings;
//视频本地相册存储管理器
@property (nonatomic, strong) ALAssetsLibrary *localVideoManager;

@end


@implementation WBNativeVideoWriter

- (instancetype)initWithVideoStoreURL:(NSString *)Url VideoAspectRationType:(WBNativeVideoAspectRatioType)aspectRationType
{
    self = [super init];
    if (self)
    {
        self.videoURL = [[NSURL alloc] initFileURLWithPath:Url];
        self.videoAspectRatioType = aspectRationType;
        [self initVariousData];
    }
    
    return self;
}

- (void)dealloc
{
    [self destroyWriter];
}


- (void)updateRecordWriterStatus:(WBNativeVideoWriterType)writerType
{
    self.writerStatus = writerType;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoWriterStatus:status:)])
    {
        [self.delegate videoWriterStatus:self status:writerType];
    }
}

- (void)initVariousData
{
    self.writerWorkingQueue = dispatch_queue_create("WBAVFrame.NativeVideoWriter.workingQueue", DISPATCH_QUEUE_SERIAL);
    self.writerStatus = WBNativeVideoWriterTypeNone;
    self.localVideoManager = [[ALAssetsLibrary alloc] init];
    switch (_videoAspectRatioType)
    {
        case WBNativeVideoAspectRatioType1x1:
            _videoOutPutSize = CGSizeMake(WBScreenWidth, WBScreenWidth);
            break;
        case WBNativeVideoAspectRatioType4X3:
            _videoOutPutSize = CGSizeMake(WBScreenWidth, WBScreenWidth*4/3);
            break;
        case WBNativeVideoAspectRatioType16x9:
            _videoOutPutSize = CGSizeMake(WBScreenWidth, WBScreenWidth*16/9);
            break;
        case WBNativeVideoAspectRatioTypeFullScreen:
            _videoOutPutSize = CGSizeMake(WBScreenWidth, WBScreenWidth);
        default:
            _videoOutPutSize = CGSizeMake(WBScreenWidth, WBScreenHeight);//默认按照全屏比例录制
            break;
    }
}

- (void)startWriter
{
    if (!self.recordWriter)
    {
        [self initRecordWriter];
    }
    
    [self updateRecordWriterStatus:WBNativeVideoWriterTypeWriting];
}

- (void)stopWriter
{
    [self updateRecordWriterStatus:WBNativeVideoWriterTypeStop];
    WEAK_SELF;
    if (self.recordWriter && self.recordWriter.status == AVAssetWriterStatusWriting)
    {
#warning WB_WARNING 一定要停止写入器！！！否则以流的形式是无法存入手机相册的！切记！！！
        //首先停止Writer
        [self.recordWriter finishWritingWithCompletionHandler:^{
            STRONG_SELF;
            //将写入的视频纳入进iOS的相册管理器中去
            [strongSelf saveRecordToLocal];
        }];
    }
}


- (void)destroyWriter
{
    self.recordWriter = nil;
    self.writerVideoInput = nil;
    self.writerAudioInput = nil;
    self.videoURL = nil;
}


- (void)initRecordWriter
{
    NSError *writerError = nil;
    self.recordWriter = [AVAssetWriter assetWriterWithURL:_videoURL fileType:AVFileTypeMPEG4 error:&writerError];
    if (writerError)
    {
        NSLog(@"AVAssetWriter Error: %@",writerError.description);
        [self updateRecordWriterStatus:WBNativeVideoWriterTypeError];
        return;
    }
    
    //待写入视频大小
    NSInteger numPixels = self.videoOutPutSize.width *self.videoOutPutSize.height;
    //每像素比特
    CGFloat bitsPerPixel = 6.0;
    NSInteger bitsPerSecond = numPixels *bitsPerPixel;
    //视频压缩选项设定:码率和帧率设置
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                             AVVideoExpectedSourceFrameRateKey : @(30),
                                             AVVideoMaxKeyFrameIntervalKey : @(30),
                                             AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel };
    //视频属性设置
    self.videoCompressionSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                       AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                       AVVideoWidthKey : @(self.videoOutPutSize.height),
                                       AVVideoHeightKey : @(self.videoOutPutSize.width),
                                       AVVideoCompressionPropertiesKey : compressionProperties };
    //写入器视频输入
    self.writerVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:_videoCompressionSettings];
    //expectsMediaDataInRealTime 必须设为yes，需要从capture session 实时获取数据
    self.writerVideoInput.expectsMediaDataInRealTime = YES;
    //控制视频展示方向，横向展示还是纵向展示，默认为纵向展示，符合正常的浏览习惯
    //self.writerVideoInput.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
    if ([self.recordWriter canAddInput:_writerVideoInput])
    {
        [self.recordWriter addInput:_writerVideoInput];
    }
    else
    {
        NSLog(@"AssetWriter videoInput append Failed");
    }

    //音频属性设置
    self.audioCompressionSettings = @{ AVEncoderBitRatePerChannelKey : @(28000),
                                       AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                       AVNumberOfChannelsKey : @(1),
                                       AVSampleRateKey : @(22050) };
    //写入器音频输入
    self.writerAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:_audioCompressionSettings];
    self.writerAudioInput.expectsMediaDataInRealTime = YES;
    if ([self.recordWriter canAddInput:_writerAudioInput])
    {
        [self.recordWriter addInput:_writerAudioInput];
    }
    else
    {
        NSLog(@"AssetWriter audioInput Append Failed");
    }
    
    //设置当前写入器状态
    [self updateRecordWriterStatus:WBNativeVideoWriterTypeReady];
    
}


//samplebuffer处理写入
- (void)writeWithSampleBuffer:(CMSampleBufferRef)sampleBuffer MediaType:(NSString *)mediaType
{
    if (!sampleBuffer)
    {
        NSLog(@"sampleBuffer nil Error !");
        return;
    }
    
    @synchronized (self)
    {
        if (self.writerStatus != WBNativeVideoWriterTypeWriting)
        {
            return;
        }
    }
    CFRetain(sampleBuffer);
    WEAK_SELF;
    dispatch_async(self.writerWorkingQueue, ^{
        
        @synchronized (weakSelf)
        {
            if (self.writerStatus != WBNativeVideoWriterTypeWriting)
            {
                NSLog(@"writer not ready yet");
                CFRelease(sampleBuffer);
                return ;
            }
        }
        //开始录制
        if (weakSelf.recordWriter.status != AVAssetWriterStatusWriting)
        {
            [weakSelf.recordWriter startWriting];
            [weakSelf.recordWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
            
            AVAssetWriterStatus status = self.recordWriter.status;
            if (status == AVAssetWriterStatusFailed)
            {
                NSLog(@"recordWriter start Failed :%@",self.recordWriter.error.description);
                [self updateRecordWriterStatus:WBNativeVideoWriterTypeError];
                return;
            }
        }
        //处理视频sampleBuffer数据
        if (mediaType == AVMediaTypeVideo)
        {
            if (weakSelf.writerVideoInput.readyForMoreMediaData)
            {
                BOOL isSuccess = [weakSelf.writerVideoInput appendSampleBuffer:sampleBuffer];
                if (!isSuccess)
                {
                    @synchronized (self)
                    {
                        [weakSelf stopWriter];
                        [weakSelf destroyWriter];
                    }
                }
            }
        }
        //处理音频sampleBuffer数据
        if (mediaType == AVMediaTypeAudio)
        {
            if (mediaType == AVMediaTypeAudio)
            {
                if (weakSelf.writerAudioInput.readyForMoreMediaData)
                {
                    BOOL isSuccess = [weakSelf.writerAudioInput appendSampleBuffer:sampleBuffer];
                    if (!isSuccess)
                    {
                        @synchronized (self)
                        {
                            [weakSelf stopWriter];
                            [weakSelf destroyWriter];
                        }
                    }
                }
            }
        }
        
        CFRelease(sampleBuffer);
    });
}

- (void)saveRecordToLocal
{
    WEAK_SELF;
    [self.localVideoManager saveVideo:_videoURL toAlbum:VIDEO_FOLDER_NAME completion:^(NSURL *assetURL, NSError *error)
    {
        if (error)
        {
            NSLog(@"录制视频保存本地相册失败 : %@",error.description);
            [weakSelf updateRecordWriterStatus:WBNativeVideoWriterTypeError];
        }
        else
        {
            NSLog(@"录制视频保存本地相册成功");
            [weakSelf updateRecordWriterStatus:WBNativeVideoWriterTypeComplete];
        }
      
    } failure:^(NSError *error)
    {
        NSLog(@"录制视频保存本地相册失败 : %@",error.description);
        [weakSelf updateRecordWriterStatus:WBNativeVideoWriterTypeError];
    }];
}




@end
