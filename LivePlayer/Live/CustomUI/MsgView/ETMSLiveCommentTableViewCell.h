//
//  ETMSLiveCommentTableViewCell.h
//  MastеrsSеriеs
//
//  Created by pptk on 2017/7/24.
//  Copyright © 2017年 8wm. All rights reserved.
//  非全屏的评论TableView Cell

#import <QMUIKit/QMUIKit.h>
#import "ETMSLiveComModel.h"

@interface ETMSLiveCommentTableViewCell : QMUITableViewCell

- (void)setCellInfo:(ETMSLiveComModel *)info;

@end
