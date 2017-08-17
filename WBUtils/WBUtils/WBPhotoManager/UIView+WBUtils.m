//
//  UIView+WB.m
//  WBTools_OC
//
//  Created by 王博 on 2017/4/13.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "UIView+WBUtils.h"

@implementation UIView (WB)
#pragma mark - Frame
- (CGFloat)WB_left {
    return self.frame.origin.x;
}

- (void)setWB_left:(CGFloat)WB_left {
    CGRect frame = self.frame;
    frame.origin.x = WB_left;
    self.frame = frame;
}


- (CGFloat)WB_top {
    return self.frame.origin.y;
}

- (void)setWB_top:(CGFloat)WB_top {
    CGRect frame = self.frame;
    frame.origin.y = WB_top;
    self.frame = frame;
}


- (CGFloat)WB_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setWB_right:(CGFloat)WB_right {
    CGRect frame = self.frame;
    frame.origin.x = WB_right - frame.size.width;
    self.frame = frame;
}


- (CGFloat)WB_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setWB_bottom:(CGFloat)WB_bottom {
    CGRect frame = self.frame;
    frame.origin.y = WB_bottom - frame.size.height;
    self.frame = frame;
}


- (CGFloat)WB_centerX {
    return self.center.x;
}

- (void)setWB_centerX:(CGFloat)WB_centerX {
    self.center = CGPointMake(WB_centerX, self.center.y);
}


- (CGFloat)WB_centerY {
    return self.center.y;
}

- (void)setWB_centerY:(CGFloat)WB_centerY {
    self.center = CGPointMake(self.center.x, WB_centerY);
}


- (CGFloat)WB_width {
    return self.frame.size.width;
}

- (void)setWB_width:(CGFloat)WB_width {
    CGRect frame = self.frame;
    frame.size.width = WB_width;
    self.frame = frame;
}


- (CGFloat)WB_height {
    return self.frame.size.height;
}

- (void)setWB_height:(CGFloat)WB_height {
    CGRect frame = self.frame;
    frame.size.height = WB_height;
    self.frame = frame;
}


- (CGPoint)WB_origin {
    return self.frame.origin;
}

- (void)setWB_origin:(CGPoint)WB_origin {
    CGRect frame = self.frame;
    frame.origin = WB_origin;
    self.frame = frame;
}


- (CGSize)WB_size {
    return self.frame.size;
}

- (void)setWB_size:(CGSize)WB_size {
    CGRect frame = self.frame;
    frame.size = WB_size;
    self.frame = frame;
}



#pragma mark - SubView
- (UIView *)WB_subviewWithTag:(NSInteger)tag {
    for (UIView *sub in self.subviews) {
        if (sub.tag == tag)
            return sub;
    }
    return nil;
}

- (void)WB_removeAllSubviews {
    while ([self.subviews count] > 0) {
        UIView *subview = [self.subviews objectAtIndex:0];
        [subview removeFromSuperview];
    }
}

- (void)WB_removeViewWithTag:(NSInteger)tag {
    if (tag == 0)
        return;
    
    UIView *view = [self viewWithTag:tag];
    if (view)
        [view removeFromSuperview];
}

- (void)WB_removeSubViewArray:(NSMutableArray *)views {
    for (UIView *sub in views) {
        [sub removeFromSuperview];
    }
}
- (void)WB_removeViewWithTags:(NSArray *)tagArray {
    for (NSNumber *num in tagArray) {
        [self WB_removeViewWithTag:[num integerValue]];
    }
}
- (void)WB_removeViewWithTagLessThan:(NSInteger)tag {
    NSMutableArray *views = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if (view.tag > 0 && view.tag < tag)
            [views addObject:view];
    }
    [self WB_removeSubViewArray:views];
}
- (void)WB_removeViewWithTagGreaterThan:(NSInteger)tag {
    NSMutableArray *views = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if (view.tag > 0 && view.tag > tag)
            [views addObject:view];
    }
    [self WB_removeSubViewArray:views];
}

#pragma mark - View Controller
- (UIViewController *)WB_responderViewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController*)nextResponder;
    }
    return nil;
}

#pragma mark - Draw Rect
- (void)WB_circular {
    [self WB_cornerRadius:self.WB_width/2.0];
}

- (void)WB_cornerRadius:(CGFloat)radius {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
}

- (void)WB_corners:(UIRectCorner)corners cornerRadius:(CGFloat)radius {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius,radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)WB_cornerRadius:(CGFloat)radius lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor {
    [self WB_cornerRadius:radius];
    self.layer.borderWidth = lineWidth;
    self.layer.borderColor = lineColor.CGColor;
}

- (void)addSpringAnimation {
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue < 9.0)
        return;

    CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
    springAnimation.fromValue = @1;
    springAnimation.toValue = @1.01;
    
    springAnimation.mass = 1;
    springAnimation.damping = 7;
    springAnimation.stiffness = 50;
    springAnimation.duration = 0.2f;
    springAnimation.initialVelocity = 200.f;
    
    [self.layer addAnimation:springAnimation forKey:nil];
}

@end
