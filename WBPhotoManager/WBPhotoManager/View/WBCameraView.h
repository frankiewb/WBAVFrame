//
//  WBCameraView.h
//  WBImagePickerController
//
//  Created by 王博 on 2017/5/2.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBCameraView : UIView

- (void)setPreviewLayerFrame:(CGRect)frame;

- (void)startSession;

- (void)stopSession;

@end
