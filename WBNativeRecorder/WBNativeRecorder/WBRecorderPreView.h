//
//  WBRecorderPreView.h
//  WBNAtiveRecorder
//
//  Created by 王博 on 2017/8/1.
//  Copyright © 2017年 王博. All rights reserved.
//


#pragma mark 美颜渲染实时展示页面，采用GLKView


#import <GLKit/GLKit.h>

@interface WBRecorderPreView : GLKView

- (void)displayPreViewWithUpdatedImage:(CIImage *)filteredImage;

@end
