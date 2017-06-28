//
//  WBAVRootBottomButtonView.m
//  WBAVFrame
//
//  Created by 王博 on 2017/6/27.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBAVRootBottomButtonView.h"

@interface WBAVRootBottomButtonView ()

@property (nonatomic, strong) NSMutableArray *functionButtonArray;

@property (nonatomic, copy) NSArray *functionButtonNameArray;

@property (nonatomic, copy) NSArray *functionButtonImageNameArray;

@property (nonatomic, copy) NSArray *functionButtonSelectedImageNameArray;

@end


@implementation WBAVRootBottomButtonView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setVariousValue];
        [self setSubView];
    }
    
    return self;
}


- (void)setVariousValue
{
    if (!self.functionButtonArray)
    {
        self.functionButtonArray = [[NSMutableArray alloc] init];
    }
    if (!self.functionButtonNameArray)
    {
        self.functionButtonNameArray =  @[@"直播",@"观看",@"礼物",@"录播",@"播放"];
    }
    if (!self.functionButtonImageNameArray)
    {
        self.functionButtonImageNameArray = @[@"wbLiveRecorder",@"wbLivePlayer",@"wbRecorder",@"wbVideoRecorder",@"wbVideoPlayer"];
    }
    if (!self.functionButtonSelectedImageNameArray)
    {
        self.functionButtonSelectedImageNameArray = @[@"wbLiveRecorder_select",@"wbLivePlayer_select",@"wbRecorder",@"wbVideoRecorder_select",@"wbVideoPlayer_select"];
    }
    
}

- (void)setSubView
{
    [self setFunctionButtons];
}


- (void)setFunctionButtons
{
    for (NSInteger buttonIndex = 0; buttonIndex < self.functionButtonNameArray.count; buttonIndex++)
    {
        UIButton *functionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        functionButton.backgroundColor = [UIColor whiteColor];
        functionButton.tag = buttonIndex;
        functionButton.frame = CGRectMake(0 + (self.frame.size.width / self.functionButtonNameArray.count)*buttonIndex, 0, self.frame.size.width / self.functionButtonNameArray.count,self.frame.size.height);
        [functionButton setImage:[UIImage imageNamed:self.functionButtonImageNameArray[buttonIndex]] forState:UIControlStateSelected];
        [functionButton setImage:[UIImage imageNamed:self.functionButtonSelectedImageNameArray[buttonIndex]] forState:UIControlStateNormal];
        [functionButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        functionButton.titleLabel.font = [UIFont systemFontOfSize:10*WBDeviceScale6];
        [functionButton setTitleColor:[UIColor colorWithHexString:@"897AEB"] forState:UIControlStateNormal];
        
        if (functionButton.tag != 2)
        {
            [functionButton setTitle:self.functionButtonNameArray[buttonIndex] forState:UIControlStateNormal];
            [self setButtonVerticalLayout:functionButton];
        }

        [functionButton addTarget:self action:@selector(functionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.functionButtonArray addObject:functionButton];
        [self addSubview:functionButton];
    }
    
    UIView *seperatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 3)];
    seperatorLine.backgroundColor = [UIColor colorWithRed:159/255.0 green:211/255.0 blue:149/255.0 alpha:1];
    [self addSubview:seperatorLine];
}


- (void)functionButtonClicked:(UIButton *)button
{
    if (self.wbAVRootBottomButtonClickHandler)
    {
        self.wbAVRootBottomButtonClickHandler((WBAVType)button.tag);
    }
}


//修改titleEdgeInsets和imageEdgeInsets实现图片与标题垂直排列,默认左image右label
- (void)setButtonVerticalLayout:(UIButton *)button
{
    
    CGFloat imageWidth  = button.imageView.frame.size.width;
    CGFloat imageHeight = button.imageView.frame.size.height;
    CGFloat labelWidth  = button.titleLabel.frame.size.width;
    CGFloat labelHeight = button.titleLabel.frame.size.height;
    
    //Image中心位置向右移动
    CGFloat imageOffsetX = (imageWidth + labelWidth) / 2 - imageWidth/2;
    //Image中心位置向上移动
    CGFloat imageOffsetY = imageHeight / 2;
    //ImageEdgeInsets
    button.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY + 10, imageOffsetX, imageOffsetY, -imageOffsetX);
    
    //Label中心位置向左移动
    CGFloat labelOffsetX = (imageWidth + labelWidth / 2) - (imageWidth + labelWidth) / 2;
    //Label中心位置向下移动
    CGFloat labelOffsetY = labelHeight / 2 + 5;
    //LabelEdgeInsets
    button.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -labelOffsetX, -labelOffsetY - 10, labelOffsetX);
}

- (void)setDefaultButtonEdgeInsets:(UIButton *)button
{
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
}



@end
