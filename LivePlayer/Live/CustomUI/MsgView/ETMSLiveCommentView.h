//
//  ETMSLiveCommentView.h
//  MastеrsSеriеs
//
//  Created by pptk on 2017/7/26.
//  Copyright © 2017年 8wm. All rights reserved.
//  非全屏的评论控件~

#import <QMUIKit/QMUIKit.h>
#import "ETMSLiveComModel.h"

@interface ETMSLiveCommentView : UIView

@property(nonatomic, strong) QMUITableView *msgTableView;
@property(nonatomic, strong) NSMutableArray<ETMSLiveComModel *> *cellInfos;

- (void)addComment:(ETMSLiveComModel *)model;

@end
