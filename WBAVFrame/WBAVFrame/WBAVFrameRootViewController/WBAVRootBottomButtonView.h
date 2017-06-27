//
//  WBAVRootBottomButtonView.h
//  WBAVFrame
//
//  Created by 王博 on 2017/6/27.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,WBAVType)
{
    WBAVTypeLiveRecorder = 0,
    WBAVTypeLivePlayer,
    WBAVTypeRecorderButton,
    WBAVTypeVideoRecorder,
    WBAVTypeVideoPlayer,
};

@interface WBAVRootBottomButtonView : UIView

@property (nonatomic, copy) void(^wbAVRootBottomButtonClickHandler)(WBAVType type);

@end
