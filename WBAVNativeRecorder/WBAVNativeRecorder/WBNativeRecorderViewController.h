//
//  WBNativeRecorderViewController.h
//  WBAVNAtiveRecorder
//
//  Created by 王博 on 2017/8/10.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBNativeRecorder.h"


@interface WBNativeRecorderViewController : UIViewController

//初始化时要指定录像器类型
- (instancetype) initWithRecorderType:(WBNativeRecorderType)type;

@end
