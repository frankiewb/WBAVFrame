//
//  WBAlbumListCell.h
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/13.
//  Copyright © 2016年 Mustard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WBAlbumModel;

static NSString * const kAlbumCellReuserIdentifier = @"WBAlbumListCellID";

@interface WBAlbumListCell : UITableViewCell

@property (strong, nonatomic) UIImage *placeholderThumbnail;

@property (strong, nonatomic) WBAlbumModel *albumModel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
