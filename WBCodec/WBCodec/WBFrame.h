//
//  WBFrame.h
//  WBCodec
//
//  Created by 王博 on 2017/7/25.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBFrame : NSObject

@property (nonatomic, assign) uint64_t timeStamp;

@property (nonatomic, strong) NSData *frameData;

@property (nonatomic, strong) NSData *frameHeader;

@end
