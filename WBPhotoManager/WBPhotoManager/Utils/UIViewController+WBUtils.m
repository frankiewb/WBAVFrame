//
//  UIViewController+Utils.m
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/13.
//  Copyright © 2016年 王博. All rights reserved.
//

#import "UIViewController+WBUtils.h"

@implementation UIViewController (WBUtils)

- (void)addNavigationRightCancelButton {
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(mp_cancelButtonDidClicked)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)mp_cancelButtonDidClicked {
    
}

- (UIAlertController *)addAlertControllerWithTitle:(NSString *)title actionTitle:(NSString *)actionTitle {
    UIAlertController *alertCtrler = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:nil];
    [alertCtrler addAction:action];
    
    return alertCtrler;
}
@end
