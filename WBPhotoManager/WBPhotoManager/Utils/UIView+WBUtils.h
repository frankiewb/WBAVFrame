//
//  UIView+WB.h
//  WBTools_OC
//
//  Created by 王博 on 2017/4/13.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface UIView (WB)

#pragma mark - Frame
@property (assign, nonatomic) CGFloat WB_left;

@property (assign, nonatomic) CGFloat WB_top;

@property (assign, nonatomic) CGFloat WB_right;

@property (assign, nonatomic) CGFloat WB_bottom;

@property (assign, nonatomic) CGFloat WB_width;

@property (assign, nonatomic) CGFloat WB_height;

@property (assign, nonatomic) CGFloat WB_centerX;

@property (assign, nonatomic) CGFloat WB_centerY;

@property (assign, nonatomic) CGPoint WB_origin;

@property (assign, nonatomic) CGSize WB_size;


#pragma mark - SubView
/**
 根据tag得到子视图
 */
- (__kindof UIView *)WB_subviewWithTag:(NSInteger)tag;

/**
 删除所有子视图
 */
- (void)WB_removeAllSubviews;

/**
 根据tag删除子视图
 */
- (void)WB_removeViewWithTag:(NSInteger)tag;

/**
 根据tag删除多个子视图
 */
- (void)WB_removeViewWithTags:(NSArray *)tagArray;

/**
 删除比该tag小的子视图
 */
- (void)WB_removeViewWithTagLessThan:(NSInteger)tag;

/**
 删除比该tag大的子视图
 */
- (void)WB_removeViewWithTagGreaterThan:(NSInteger)tag;


#pragma mark - View Controller
/**
 得到该视图所在的视图控制器
 */
- (__kindof UIViewController *)WB_responderViewController;

#pragma mark - Draw Rect
//设置圆角
- (void)WB_cornerRadius:(CGFloat)radius;

//设置圆角线框
- (void)WB_cornerRadius:(CGFloat)radius lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor;

//设置某几个角为圆角
- (void)WB_corners:(UIRectCorner)corners cornerRadius:(CGFloat)radius;

//设置圆形
- (void)WB_circular;

/** 添加点击弹簧动画 */
- (void)addSpringAnimation;

@end
