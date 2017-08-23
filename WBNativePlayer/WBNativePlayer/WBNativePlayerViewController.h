//
//  WBNativePlayerViewController.h
//  WBNativePlayer
//
//  Created by 王博 on 2017/8/23.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBNativePlayerViewController : UIViewController

//设置即将播放的视频URL
- (void)setVideoViewURL:(NSURL *)videoURL;

//设置即将播放视频的Placeholder
- (void)setVideoViewPlaceholder:(UIImage *)placeholderImage;

//设置视频标题
- (void)setVideoViewTitle:(NSString *)videoTitle;


@end
