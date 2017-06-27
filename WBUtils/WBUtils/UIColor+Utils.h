//
//  UIColor+Utils.h
//  WBUtils
//
//  Created by WangBo on 2017/6/27.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utils)

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert alpha:(float) alpha;

@end
