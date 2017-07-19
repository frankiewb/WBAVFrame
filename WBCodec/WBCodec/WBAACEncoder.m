//
//  WBAACEncoder.m
//  WBCodec
//
//  Created by 王博 on 2017/6/28.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBAACEncoder.h"


@interface WBAACEncoder ()

@property (nonatomic, assign) AudioConverterRef wbAudioConverter; //AAC音频编码器具柄

@property (nonatomic, assign) uint8_t *aacBuffer;

@property (nonatomic, assign) NSUInteger aacBufferSize;

@property (nonatomic, assign) char *pcmBuffer;

@property (nonatomic, assign) size_t pcmBufferSize;

@property (nonatomic, strong) dispatch_queue_t aacEncodeQueue;//视频编码处理队列

@end

@implementation WBAACEncoder

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setVariousData];
    }
    
    return self;
}

- (void)setVariousData
{
    self.aacEncodeQueue = dispatch_queue_create("WB_AAC_ENCODER_QUEUE", DISPATCH_QUEUE_SERIAL);
    self.wbAudioConverter = nil;
    self.pcmBufferSize = 0;
    self.pcmBuffer = nil;
    self.aacBufferSize = 1024;
    self.aacBuffer = malloc(_aacBufferSize *sizeof(uint8_t));
    memset(_aacBuffer, 0, _aacBufferSize);
}

- (void)initAACEncoderWithSmapleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (_wbAudioConverter) return;
    
    //1.输入音频流描述
    AudioStreamBasicDescription inAudioStreamBasicDescription = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));
    inAudioStreamBasicDescription.mSampleRate = 44100; // 默认音频码率，默认为64Kbps 44.1Hz 采样率 44100
    
    //2.输出音频流描述
    AudioStreamBasicDescription outAudioStreamBasicDescription = {0};//初始化输出流的结构体，描述为0
    outAudioStreamBasicDescription.mSampleRate = inAudioStreamBasicDescription.mSampleRate;//音频流在正常播放情况下的帧率，如果是压缩的格式，这个属性表示压缩后的帧率，帧率不能为0
    outAudioStreamBasicDescription.mFormatID = kAudioFormatMPEG4AAC;//设置编码格式
    outAudioStreamBasicDescription.mFormatFlags = kMPEG4Object_AAC_LC;//无损编码，0表示没有
    outAudioStreamBasicDescription.mBytesPerPacket = 0;//每一个packet的音频数据大小，设为0表示动态大小，需要用AudioStreamPacketDescription来确定每个packet的大小
    outAudioStreamBasicDescription.mFramesPerPacket = 1024;//每个packet的帧数，如果是未压缩的音频数据则值为1.动态帧率格式，是一个交大的固定数字，AAC为1024，如果是动态大小帧数（比如Ogg格式）则设置为0；
    outAudioStreamBasicDescription.mBytesPerFrame = 0;//每帧的大小。每一帧的起始点到下一帧的起始点，如果是压缩格式，设置为0
    outAudioStreamBasicDescription.mChannelsPerFrame = 1;//声道数
    outAudioStreamBasicDescription.mBitsPerChannel = 0;//压缩格式设置为0
    outAudioStreamBasicDescription.mReserved = 0;//8字节对齐，填0
    
    
    //生成音频转换器
    AudioClassDescription *audioClassDes = [self getAudioClassDescriptionWithType:kAudioFormatMPEG4AAC fromManufacturer:kAppleSoftwareAudioCodecManufacturer];//软编码
    if (!audioClassDes)
    {
        NSLog(@"setup converter  audioClassDes error ！");
    }
    
    OSStatus audioConverterStatus = AudioConverterNewSpecific(&inAudioStreamBasicDescription, &outAudioStreamBasicDescription, 1, audioClassDes, &_wbAudioConverter);
    if (audioClassDes != 0)
    {
        NSLog(@"setup converter: %d", audioConverterStatus);
    }
    
}

/**
 *  获取编解码器
 *
 *  @param type         编码格式
 *  @param manufacturer 软/硬编
 *
 编解码器（codec）指的是一个能够对一个信号或者一个数据流进行变换的设备或者程序。这里指的变换既包括将 信号或者数据流进行编码（通常是为了传输、存储或者加密）或者提取得到一个编码流的操作，也包括为了观察或者处理从这个编码流中恢复适合观察或操作的形式的操作。编解码器经常用在视频会议和流媒体等应用中。
 *  @return 指定编码器
 */
- (AudioClassDescription *)getAudioClassDescriptionWithType:(UInt32)type fromManufacturer:(UInt32)manufacturer
{
    static AudioClassDescription audioEncoderDes;
    UInt32 audioEncoderSpecifier = type;
    OSStatus audioGenerateStatus;
    UInt32 size;
    
    audioGenerateStatus = AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders, sizeof(audioEncoderSpecifier), &audioEncoderSpecifier, &size);
    if (audioGenerateStatus)
    {
        NSLog(@"error getting audio format propery info: %d", audioGenerateStatus);
        return nil;
    }
    
    unsigned int count = size / sizeof(AudioClassDescription);
    AudioClassDescription descriptions[count];
    audioGenerateStatus = AudioFormatGetProperty(kAudioFormatProperty_Encoders,
                                sizeof(audioEncoderSpecifier),
                                &audioEncoderSpecifier,
                                &size,
                                descriptions);
    
    if (audioGenerateStatus)
    {
        NSLog(@"error getting audio format propery : %d", audioGenerateStatus);
        return nil;
    }
    
    for (unsigned int i = 0; i < count; i++)
    {
        if ((type == descriptions[i].mSubType) &&
            (manufacturer == descriptions[i].mManufacturer))
        {
            memcpy(&audioEncoderDes, &(descriptions[i]), sizeof(audioEncoderDes));
            return &audioEncoderDes;
        }
    }
    
    return nil;
}





- (void)encodeWithSampleBuffer:(CMSampleBufferRef)sampleBuffer timeStamp:(uint64_t)timeStamp
{
    CFRetain(sampleBuffer);
    
    dispatch_async(_aacEncodeQueue, ^
    {
        [self initAACEncoderWithSmapleBuffer:sampleBuffer];
        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
        CFRetain(blockBuffer);
        OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &_pcmBufferSize, &_pcmBuffer);
        NSError *error = nil;
        if (status != kCMBlockBufferNoErr)
        {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        memset(_aacBuffer, 0, _aacBufferSize);
        
        AudioBufferList outAudioBufferList = {0};
        outAudioBufferList.mNumberBuffers = 1;
        outAudioBufferList.mBuffers[0].mNumberChannels = 1;
        outAudioBufferList.mBuffers[0].mDataByteSize = (int)_aacBufferSize;
        outAudioBufferList.mBuffers[0].mData = _aacBuffer;
        AudioStreamPacketDescription *outPacketDescription = NULL;
        UInt32 ioOutputDataPacketSize = 1;
        status = AudioConverterFillComplexBuffer(_wbAudioConverter, inInputDataProc, (__bridge void *)(self), &ioOutputDataPacketSize, &outAudioBufferList, outPacketDescription);
        NSData *data = nil;
        if (status == 0)
        {
            NSData *rawAAC = [NSData dataWithBytes:outAudioBufferList.mBuffers[0].mData length:outAudioBufferList.mBuffers[0].mDataByteSize];
            NSData *adtsHeader = [self adtsDataForPacketLength:rawAAC.length];
            NSMutableData *fullData = [NSMutableData dataWithData:adtsHeader];
            [fullData appendData:rawAAC];
            data = fullData;
        } else
        {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        WBAudioFrame *audioFrame = [[WBAudioFrame alloc] init];
        audioFrame.timeStamp = timeStamp;
        audioFrame.frameData = [NSData dataWithBytes:_aacBuffer length:outAudioBufferList.mBuffers[0].mDataByteSize];
        
//        // flv编码音频头 44100 为0x12 0x10
//        char *asc = malloc(2);  // 开辟两个长度的字节
//        asc[0] = 0x10 | ((4>>1) & 0x3);
//        asc[1] = ((4 & 0x1)<<7) | ((1 & 0xF) << 3);
//        audioFrame.audioInfo =  [NSData dataWithBytes:asc length:2];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(wbAACEncoderDidFinishEncodeWithWBAudioFrame:)])
        {
            [self.delegate wbAACEncoderDidFinishEncodeWithWBAudioFrame:audioFrame];
        }
        
        CFRelease(sampleBuffer);
        CFRelease(blockBuffer);
    });
    
    
    
}

OSStatus inInputDataProc(AudioConverterRef inAudioConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData)
{
    
    WBAACEncoder *encoder = (__bridge WBAACEncoder *)(inUserData);
    UInt32 requestedPackets = *ioNumberDataPackets;
    
    size_t copiedSamples = [encoder copyPCMSamplesIntoBuffer:ioData];
    if (copiedSamples < requestedPackets) {
        //PCM 缓冲区还没满
        *ioNumberDataPackets = 0;
        return -1;
    }
    *ioNumberDataPackets = 1;    
    return noErr;
}


/**
 *  填充PCM到缓冲区
 */
- (size_t) copyPCMSamplesIntoBuffer:(AudioBufferList*)ioData {
    size_t originalBufferSize = _pcmBufferSize;
    if (!originalBufferSize) {
        return 0;
    }
    ioData->mBuffers[0].mData = _pcmBuffer;
    ioData->mBuffers[0].mDataByteSize = (int)_pcmBufferSize;
    _pcmBuffer = NULL;
    _pcmBufferSize = 0;
    return originalBufferSize;
}

/**
 *  Add ADTS header at the beginning of each and every AAC packet.
 *  This is needed as MediaCodec encoder generates a packet of raw
 *  AAC data.
 *
 *  Note the packetLen must count in the ADTS header itself.
 *  See: http://wiki.multimedia.cx/index.php?title=ADTS
 *  Also: http://wiki.multimedia.cx/index.php?title=MPEG-4_Audio#Channel_Configurations
 **/
- (NSData*) adtsDataForPacketLength:(NSUInteger)packetLength {
    int adtsLength = 7;
    char *packet = malloc(sizeof(char) * adtsLength);
    // Variables Recycled by addADTStoPacket
    int profile = 2;  //AAC LC
    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
    int freqIdx = 4;  //44.1KHz
    int chanCfg = 1;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
    NSUInteger fullLength = adtsLength + packetLength;
    // fill in ADTS data
    packet[0] = (char)0xFF; // 11111111     = syncword
    packet[1] = (char)0xF9; // 1111 1 00 1  = syncword MPEG-2 Layer CRC
    packet[2] = (char)(((profile-1)<<6) + (freqIdx<<2) +(chanCfg>>2));
    packet[3] = (char)(((chanCfg&3)<<6) + (fullLength>>11));
    packet[4] = (char)((fullLength&0x7FF) >> 3);
    packet[5] = (char)(((fullLength&7)<<5) + 0x1F);
    packet[6] = (char)0xFC;
    NSData *data = [NSData dataWithBytesNoCopy:packet length:adtsLength freeWhenDone:YES];
    return data;
}



@end
