//
//  WBRtmpStreamInfo.h
//  WBRtmpHandler
//
//  Created by 王博 on 2017/7/19.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, WBLiveStateType)
{
    WBLiveStateTypeReady = 0,//准备
    WBLiveStateTypeConnecting,//连接中
    WBLiveStateTypeConnected,//已连接
    WBLiveStateTypeStop,//已断开
    WBLiveStateTypeError,//连接出错
};


typedef NS_ENUM(NSInteger,WBLiveSocketErrorType)
{
    WBLiveSocketErrorTypePreView = 201,//预览失败
    WBLiveSocketErrorTypeGetStreamInfo = 202,//获取流媒体信息失败
    WBLiveSocketErrorTypeConnectSocket = 203,//连接socket失败
    WBLiveSocketErrorTypeVerification = 204,//验证服务器失败
    WBLiveSocketErrorTypeReconnectTimeOut = 205,//重新连接服务器超时
};

@interface WBRtmpStreamInfo : NSObject

@property (nonatomic, copy) NSString *streamID;

@property (nonatomic, copy) NSString *token;

@property (nonatomic, copy) NSString *url;//RTMP 上传地址

@property (nonatomic, copy) NSString *hostIP;//上传IP

@property (nonatomic, assign) NSInteger port;//上传端口


@end
