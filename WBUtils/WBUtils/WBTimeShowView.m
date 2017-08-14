//
//  WBTimeShowView.m
//  WBUtils
//
//  Created by 王博 on 2017/8/14.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBTimeShowView.h"
#import "UIColor+Utils.h"

@interface WBTimeShowView ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIView *redPoint;

@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation WBTimeShowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setSubView];
    }
    
    return self;
}

- (void)setSubView
{
    //bgView
    self.bgView = [[UIView alloc] initWithFrame:self.bounds];
    self.bgView.backgroundColor = [UIColor colorWithRGB:0x242424 alpha:0.7];
    self.bgView.layer.cornerRadius = 4;
    self.bgView.layer.masksToBounds = YES;
    [self addSubview:_bgView];
    
    //redPoint
    self.redPoint = [[UIView alloc] init];
    self.redPoint.frame = CGRectMake(0, 2, 16, 16);
    self.redPoint.layer.cornerRadius = 8;
    self.redPoint.layer.masksToBounds = YES;
    self.redPoint.center = CGPointMake(25, 17);
    self.redPoint.backgroundColor = [UIColor redColor];
    [self.bgView addSubview:_redPoint];
    
    //timeLabel
    self.timeLabel =[[UILabel alloc] init];
    self.timeLabel.font = [UIFont systemFontOfSize:16];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.frame = CGRectMake(40, 8, 40, 28);
    [self.bgView addSubview:_timeLabel];
}

- (void)updateTimeText:(CGFloat)videoTime
{
    self.timeLabel.text = [NSString stringWithFormat:@"%02li:%02li",lround(floor(videoTime/60.f)),lround(floor(videoTime/1.f))%60];
    [self.timeLabel sizeToFit];
}


@end
