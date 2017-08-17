//
//  UIViewController+Utils.h
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/13.
//  Copyright © 2016年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (WBUtils)

- (void)addNavigationRightCancelButton;

- (UIAlertController *)addAlertControllerWithTitle:(NSString *)title actionTitle:(NSString *)actionTitle;
@end
