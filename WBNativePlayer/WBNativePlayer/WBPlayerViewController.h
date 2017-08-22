//
//  WBPlayerViewController.h
//  WBNativePlayer
//
//  Created by 王博 on 2017/8/18.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  NS_ENUM(NSInteger,WBPlayerType)
{
    WBPlayerTypeNativePlayer = 1,
    WBPlayerTypeIJKPlayer,
};

@interface WBPlayerViewController : UIViewController

- (instancetype)initWithPlayerType:(WBPlayerType)type;

@end
