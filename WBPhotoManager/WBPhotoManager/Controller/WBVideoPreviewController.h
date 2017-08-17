//
//  WBVideoPreviewController.h
//  WBImagePickerController
//
//  Created by 王博 on 2016/11/2.
//  Copyright © 2016年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/PHAsset.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface WBVideoPreviewController : AVPlayerViewController

- (instancetype)initWithAsset:(PHAsset *)asset;
- (instancetype)initWithURL:(NSURL *)url;
@end
