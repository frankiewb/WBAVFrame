//
//  WBRtmpHandler.m
//  WBRtmpHandler
//
//  Created by 王博 on 2017/6/27.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBRtmpHandler.h"
#import "rtmp.h"
#import "WBAudioFrame.h"
#import "WBVideoFrame.h"
#import "WBMacros.h"


#define DATA_ITEMS_MAX_COUNT 100
#define RTMP_DATA_RESERVE_SIZE 400

#define RTMP_CONNECTION_TIMEOUT 1500
#define RTMP_RECEIVE_TIMEOUT    2

/*定义包头长度,RTMP_MAX_HEADER_SIZE为rtmp.h中定义值为18*/
#define RTMP_HEAD_SIZE (sizeof(RTMPPacket)+RTMP_MAX_HEADER_SIZE)

static const NSUInteger defaultFrameListMaxCount = 10; ///< 排序10个内



@interface WBRtmpHandler ()

@property (nonatomic, assign) RTMP *rtmpHandler;

@property (nonatomic, strong) WBRtmpStreamInfo *streamInfo;

@property (nonatomic, strong) dispatch_queue_t rtmpSocketQueue;

@property (nonatomic, assign) NSInteger retryTimes4networkBreaken;

@property (nonatomic, assign) WBLiveStateType liveStatusType;

@property (nonatomic, assign) BOOL isSendVideoHead;//是否发送了视频头部信息

@property (nonatomic, assign) BOOL isSendAudioHead;//是否发送了音频头部信息

@property (nonatomic, assign) BOOL isSendingFrame;//是否正在发送帧

@property (nonatomic, strong) NSMutableArray <WBFrame *>*bufferPoolFrameList;//缓冲池帧队列

@end


@implementation WBRtmpHandler



#pragma mark 初始化相关

- (instancetype)initWithStreamInfo:(WBRtmpStreamInfo *)streamInfo
{
    self = [super init];
    if (self)
    {
        self.streamInfo = streamInfo;
        self.rtmpSocketQueue = dispatch_queue_create("com.wangbo.rtmp.socketQueue", NULL);
        self.liveStatusType = WBLiveStateTypeReady;
        self.bufferPoolFrameList = [[NSMutableArray alloc] init];
    }

    return self;
}

//清空参数
- (void)resetVariousData
{
    self.liveStatusType = WBLiveStateTypeReady;
    self.isSendVideoHead = NO;
    self.isSendAudioHead = NO;
    self.isSendingFrame = NO;
    self.retryTimes4networkBreaken = 0;
    @synchronized (self)
    {
        [self.bufferPoolFrameList removeAllObjects];
    }
}

- (void)destroyRTMPHandler
{
    if (self.rtmpHandler)
    {
        RTMP_Close(_rtmpHandler);
        RTMP_Free(_rtmpHandler);
    }
}


#pragma mark RTMP连接相关

//初始化并创建RTMP连接

- (NSInteger)createRTMPConnectWithPushURL:(NSString *)pushURL
{
    NSInteger rtmpCreateStatus = 0;
    //1.处理RTMP状态
    if (self.liveStatusType != WBLiveStateTypeConnecting)
    {
        self.liveStatusType = WBLiveStateTypeConnecting;
    }
    else
    {
        return  -1;// RTMP正在连接中，不允许再次连接
    }
    //2.创建RTMP实例
    [self destroyRTMPHandler];
    self.rtmpHandler = RTMP_Alloc();//创建一个RTMP会话句柄
    RTMP_Init(_rtmpHandler);//初始化句柄
    
    //3.设置会话参数URL
    rtmpCreateStatus = RTMP_SetupURL(_rtmpHandler, (char *)[_streamInfo.url cStringUsingEncoding:NSASCIIStringEncoding]);
    if (rtmpCreateStatus < 0)
    {
        NSLog(@"RTMP_SetupURL Error");
        return [self rtmpConnectFailedHanler];
    }
    
    //4.设置发布流
    RTMP_EnableWrite(_rtmpHandler);
    
    //5.连接超时设置
    self.rtmpHandler->Link.timeout = RTMP_RECEIVE_TIMEOUT;
    
    //6. 连接服务器
    rtmpCreateStatus = RTMP_Connect(_rtmpHandler, NULL);
    if (rtmpCreateStatus < 0)
    {
        NSLog(@"RTMP_Connect_Error");
        return [self rtmpConnectFailedHanler];
    }
    
    //7. 连接流
    rtmpCreateStatus = RTMP_ConnectStream(_rtmpHandler, 0);
    if (rtmpCreateStatus < 0)
    {
        NSLog(@"RTMP_ConnectStream_Error");
        return [self rtmpConnectFailedHanler];
    }
    
    //8.整体连接成功
    self.liveStatusType = WBLiveStateTypeConnected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)])
    {
        [self.delegate socketStatus:self status:WBLiveStateTypeConnected];
    }
    return  0;
}


- (NSInteger)rtmpConnectFailedHanler
{
    [self destroyRTMPHandler];
    [self resetVariousData];
    self.liveStatusType = WBLiveStateTypeError;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)])
    {
        [self.delegate socketStatus:self status:WBLiveStateTypeError];
    }

    return -1;
}


#pragma mark RTMP操作相关
// 开始连接
- (void) start
{
    dispatch_async(_rtmpSocketQueue, ^{
        
        if (!_streamInfo || (_liveStatusType == WBLiveStateTypeConnecting) || !_rtmpHandler) return ;
        
//        [self WB_RTMP264_Connect:(char *)[self.streamInfo.url cStringUsingEncoding:NSASCIIStringEncoding]];
        
    });
}

//暂停连接
- (void)stop
{
    dispatch_async(_rtmpSocketQueue, ^{
        
        [self destroyRTMPHandler];
        [self resetVariousData];
    });
}


//发送帧数据
- (void)sendWBFrame:(WBFrame *)frame
{
    if (!frame) return;
    dispatch_async(_rtmpSocketQueue, ^{
        
        //1. 首先将帧放入缓冲池中
        [self frameBufferPoolHanlerWithWBFrame:frame];
        //2. 发送去除冗余包
        [self sendBufferListFrame];
    });
}


//发送去除冗余包
- (void)sendBufferListFrame
{
    if (self.liveStatusType != WBLiveStateTypeConnected || self.isSendingFrame || self.bufferPoolFrameList.count == 0)
    {
        return;
    }
    self.isSendingFrame = YES;
    //取出当前待发送帧
    WBFrame *readySendFrame = [self getReadySendFrame];
    if (readySendFrame)
    {
        //音频帧发送流程
        if ([readySendFrame isKindOfClass:[WBVideoFrame class]])
        {
            [self sendVideo:(WBVideoFrame *)readySendFrame];
        }
        //视频帧发送流程
        else if ([readySendFrame isKindOfClass:[WBAudioFrame class]])
        {
            [self sendAudio:(WBAudioFrame *)readySendFrame];
        }
    }
}



//缓冲池处理
- (void)frameBufferPoolHanlerWithWBFrame:(WBFrame *)frame
{
    if (!frame) return;
    @synchronized (self)
    {
        //加入缓冲池
        [self.bufferPoolFrameList addObject:frame];
       
        
        //对将入发送队列的缓冲池数据按时间戳进行排序
        if (self.bufferPoolFrameList.count >= 2)
        {
            NSArray *sortedBufferPoolFrameList = [self.bufferPoolFrameList sortedArrayUsingFunction:frameDataCompare context:nil];
            [self.bufferPoolFrameList removeAllObjects];
            [self.bufferPoolFrameList addObjectsFromArray:sortedBufferPoolFrameList];
        }
        
        //判断缓冲池帧队列是否已满，如果已满需要丢弃第一个P帧到第一个I帧之间的P帧
        if (self.bufferPoolFrameList.count > defaultFrameListMaxCount)
        {
            //获取当前待发送队列中第一个P帧到一个I帧之间的P帧队列
            NSMutableArray *pFramesArray = [[NSMutableArray alloc] init];
            for (NSInteger pframeIndex = 0; pframeIndex < self.bufferPoolFrameList.count; pframeIndex++)
            {
                WBFrame *singleFrame = [self.bufferPoolFrameList objectAtIndex:pframeIndex];
                if ([singleFrame isKindOfClass:[WBVideoFrame class]])
                {
                    
                    //如果在I帧前有P帧则将所有P帧都取出
                    WBVideoFrame *singleVideoFrame = (WBVideoFrame *)singleFrame;
                    
                    if (singleVideoFrame.isKeyFrame)
                    {
                        //若当前帧为I帧则删除当前I帧并返回
                        if (pframeIndex == 0)
                        {
                            [pFramesArray addObject:singleVideoFrame];
                        }
                        break;
                    }
                    else
                    {
                        [pFramesArray addObject:singleVideoFrame];
                    }
                }
            }
            //将缓冲队列里的冗余P帧都删除/或者是时间戳中最靠前的I帧（为下一次去处冗余P帧做准备)
            [self.bufferPoolFrameList removeObjectsInArray:pFramesArray];
        }
    }
}

#pragma mark 音频/视频帧处理相关函数


// 发送视频包头
// H.264 的编码信息帧是发送给 RTMP 服务器称为 AVC sequence header，RTMP 服务器只有收到 AVC sequence header 中的 sps, pps 才能解析后续发送的 H264 帧
- (void)sendVideoHead:(WBVideoFrame *)videoFrame
{
    if (!videoFrame.spsData || !videoFrame.ppsData) return;
    
    unsigned char * body    =NULL;
    NSInteger iIndex        = 0;
    NSInteger rtmpLength    = 1024;
    const char *sps         = videoFrame.spsData.bytes;
    const char *pps         = videoFrame.ppsData.bytes;
    NSInteger sps_len       = videoFrame.spsData.length;
    NSInteger pps_len       = videoFrame.ppsData.length;
    
    body = (unsigned char*)malloc(rtmpLength);
    memset(body,0,rtmpLength);  // 函数常用于内存空间初始化 用来对一段内存空间全部设置为某个字符，一般用在对定义的字符串进行初始化为‘ ’或‘/0’
    
    body[iIndex++] = 0x17;
    body[iIndex++] = 0x00;
    
    body[iIndex++] = 0x00;
    body[iIndex++] = 0x00;
    body[iIndex++] = 0x00;
    
    body[iIndex++] = 0x01;
    body[iIndex++] = sps[1];
    body[iIndex++] = sps[2];
    body[iIndex++] = sps[3];
    body[iIndex++] = 0xff;
    
    /*sps*/
    body[iIndex++]   = 0xe1;
    body[iIndex++] = (sps_len >> 8) & 0xff;
    body[iIndex++] = sps_len & 0xff;
    memcpy(&body[iIndex],sps,sps_len);  // 用来做内存拷贝，你可以拿它拷贝任何数据类型的对象，可以指定拷贝的数据长度
    iIndex +=  sps_len;
    
    /*pps*/
    body[iIndex++]   = 0x01;
    body[iIndex++] = (pps_len >> 8) & 0xff;
    body[iIndex++] = (pps_len) & 0xff;
    memcpy(&body[iIndex], pps, pps_len);
    iIndex +=  pps_len;
    
    /*调用发送接口*/
    [self sendPacket:RTMP_PACKET_TYPE_VIDEO data:body size:iIndex nTimestamp:0];
    free(body);
}


- (void)sendVideo:(WBVideoFrame*)videoFrame
{
    if(!videoFrame || !videoFrame.frameData || videoFrame.frameData.length < 11) return;
    
    //如果没有发送过视频解析头，先发送一次视频头
    if (!self.isSendVideoHead)
    {
        self.isSendVideoHead = YES;
        [self sendVideoHead:videoFrame];
        return;
    }
    
    //若发送完视频头则后续帧发送视频体
    NSInteger i = 0;
    NSInteger rtmpLength = videoFrame.frameData.length+9;
    unsigned char *body = (unsigned char*)malloc(rtmpLength);
    memset(body,0,rtmpLength);
    
    if(videoFrame.isKeyFrame){
        body[i++] = 0x17;// 1:Iframe  7:AVC
    } else{
        body[i++] = 0x27;// 2:Pframe  7:AVC
    }
    body[i++] = 0x01;// AVC NALU
    body[i++] = 0x00;
    body[i++] = 0x00;
    body[i++] = 0x00;
    body[i++] = (videoFrame.frameData.length >> 24) & 0xff;
    body[i++] = (videoFrame.frameData.length >> 16) & 0xff;
    body[i++] = (videoFrame.frameData.length >>  8) & 0xff;
    body[i++] = (videoFrame.frameData.length ) & 0xff;
    memcpy(&body[i],videoFrame.frameData.bytes,videoFrame.frameData.length);
    
    [self sendPacket:RTMP_PACKET_TYPE_VIDEO data:body size:(rtmpLength) nTimestamp:videoFrame.timeStamp];
    free(body);

}

- (void)sendAudioHead:(WBAudioFrame *)audioFrame
{
    if(!audioFrame || !audioFrame.audioFrameInfo) return;
    
    NSInteger rtmpLength = audioFrame.audioFrameInfo.length + 2;/*spec data长度,一般是2*/
    unsigned char * body = (unsigned char*)malloc(rtmpLength);
    memset(body,0,rtmpLength);
    
    /*AF 00 + AAC RAW data*/
    body[0] = 0xAF;
    body[1] = 0x00;
    memcpy(&body[2],audioFrame.audioFrameInfo.bytes,audioFrame.audioFrameInfo.length); /*spec_buf是AAC sequence header数据*/
    [self sendPacket:RTMP_PACKET_TYPE_AUDIO data:body size:rtmpLength nTimestamp:0];
    free(body);
}

- (void)sendAudio:(WBAudioFrame*)audioFrame
{
    if(!audioFrame) return;
    
    //如果没有发送过音频解析头，先发送一次音频解析头
    if (!self.isSendAudioHead)
    {
        self.isSendAudioHead = YES;
        [self sendAudioHead:audioFrame];
        return;
    }
    
    //若发完音频头则后续直接发送音频体
    NSInteger rtmpLength = audioFrame.frameData.length + 2;/*spec data长度,一般是2*/
    unsigned char * body = (unsigned char*)malloc(rtmpLength);
    memset(body,0,rtmpLength);
    
    /*AF 01 + AAC RAW data*/
    body[0] = 0xAF;
    body[1] = 0x01;
    memcpy(&body[2],audioFrame.frameData.bytes,audioFrame.frameData.length);
    [self sendPacket:RTMP_PACKET_TYPE_AUDIO data:body size:rtmpLength nTimestamp:audioFrame.timeStamp];
    free(body);
}

/**
 根据包类型 来发送包, 这里主要分为 视频包和语音包
 
 @param nPacketType 包类型  RTMP_PACKET_TYPE_VIDEO(视频包类型) RTMP_PACKET_TYPE_AUDIO(音频包类型)
 @param data 包内容
 @param size 包的大小
 @param nTimestamp 时间戳
 @return 返回int 值, 来判断是否发送成功
 */
-(NSInteger) sendPacket:(unsigned int)nPacketType data:(unsigned char *)data size:(NSInteger) size nTimestamp:(uint64_t) nTimestamp
{
    NSInteger rtmpLength = size;
    RTMPPacket rtmp_pack;   // 创建RTMP 包
    /*分配包内存和初始化*/
    RTMPPacket_Reset(&rtmp_pack);
    RTMPPacket_Alloc(&rtmp_pack,(uint32_t)rtmpLength);
    
    rtmp_pack.m_nBodySize = (uint32_t)size;
    memcpy(rtmp_pack.m_body,data,size);
    rtmp_pack.m_hasAbsTimestamp = 0;
    rtmp_pack.m_packetType = nPacketType;
    if(_rtmpHandler)
    {
        rtmp_pack.m_nInfoField2 = _rtmpHandler->m_stream_id;
    }
    rtmp_pack.m_nChannel = 0x04;
    rtmp_pack.m_headerType = RTMP_PACKET_SIZE_LARGE;
    if (RTMP_PACKET_TYPE_AUDIO == nPacketType && size !=4)
    {
        rtmp_pack.m_headerType = RTMP_PACKET_SIZE_MEDIUM;
    }
    rtmp_pack.m_nTimeStamp = (uint32_t)nTimestamp;
    
    NSInteger nRet;
    if (RTMP_IsConnected(_rtmpHandler))
    {
        int success = RTMP_SendPacket(_rtmpHandler,&rtmp_pack,0);    // true 为放进发送队列, false 不放进发送队列直接发送
        if(success)
        {
            //发送成功后继续发送
            self.isSendingFrame = NO;
            [self sendBufferListFrame];
        }
        nRet = success;
    } else
    {
        nRet = -1;
    }
    RTMPPacket_Free(&rtmp_pack);
    return nRet;
}



#pragma mark 公共方法

//排序方法
NSInteger frameDataCompare(id obj1, id obj2, void *context)
{
    WBFrame * frame1 = (WBFrame*) obj1;
    WBFrame *frame2 = (WBFrame*) obj2;
    
    if (frame1.timeStamp == frame2.timeStamp)
        return NSOrderedSame;
    else if(frame1.timeStamp > frame2.timeStamp)
        return NSOrderedDescending;
    return NSOrderedAscending;
}

//取出待发送缓存队列按时间戳排序最靠前时间对应帧
-(WBFrame *)getReadySendFrame
{
    @synchronized (self)
    {
        WBFrame *firstFrame = nil;
        if (self.bufferPoolFrameList && self.bufferPoolFrameList.count > 0)
        {
            firstFrame = [self.bufferPoolFrameList objectAtIndex:0];
            [self.bufferPoolFrameList removeObjectAtIndex:0];
        }
        
        return firstFrame;
    }
}




@end
