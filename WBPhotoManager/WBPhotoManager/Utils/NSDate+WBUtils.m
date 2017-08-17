//
//  NSDate+WBUtils.m
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/18.
//  Copyright © 2016年 王博. All rights reserved.
//

#import "NSDate+WBUtils.h"

@implementation NSDate (WBUtils)

- (NSString *)stringByPhotosMomentsType:(WBImageMomentGroupType)type {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    
    switch (type) {
        case WBImageMomentGroupTypeYear:
            //年
            [dateFormatter setDateFormat:@"YYYY"];
            break;
        case WBImageMomentGroupTypeMonth:
            //月
            if ([[NSLocale currentLocale].localeIdentifier isEqualToString:@"zh-CN"]) {
                [dateFormatter setDateFormat:@"YYYY MMMM"];
            } else {
                [dateFormatter setDateFormat:@"MMMM YYYY"];
            }
            [dateFormatter setLocale:[NSLocale currentLocale]];
            break;
        case WBImageMomentGroupTypeDay:
            //日
            [dateFormatter setDateStyle:NSDateFormatterFullStyle];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            break;
        default:
            break;
    }

    return [dateFormatter stringFromDate:self];
}

@end
