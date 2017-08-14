//
//  WBRecordCircleProgressView.h
//  WBAVNAtiveRecorder
//
//  Created by 王博 on 2017/8/14.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBRecordCircleProgressView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

-(void)updateProgressWithValue:(CGFloat)progress;

-(void)resetProgress;


@end
