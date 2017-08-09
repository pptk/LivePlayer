//
//  ETMSLiveViewController+UI.m
//  MastеrsSеriеs
//
//  Created by pptk on 2017/7/24.
//  Copyright © 2017年 8wm. All rights reserved.
//

#import "ETMSLiveViewController+UI.h"
#import "ETMSLiveCommentTableViewCell.h"
#import <Masonry/Masonry.h>
#import "ETMSLiveViewController+ImListener.h"

@implementation ETMSLiveViewController (UI)

#pragma mark - 所有地方发送的评论都回调到这里
- (void)sendComment:(NSString *)text{//inputView发送评论回调
    [self sendText:text];
}
- (void)sendCommentText:(NSString *)text{//全屏时发送评论回调
    [self sendText:text];
}
- (void)sendText:(NSString *)text{
//    ILVLiveTextMessage *msg = [[ILVLiveTextMessage alloc]init];
//    msg.type = ILVLIVE_IMTYPE_GROUP;
//    msg.text = text;
//    [self onTextMessage:msg];//调试所用，正式删除，并且开放下面代码
    ETMSLiveComModel *model = [[ETMSLiveComModel alloc]init];
    model.userId = @"111";
    model.name = @"names";
    model.head = @"live_emotion_icon";
    model.comment = text;
    [self onTextMessage:model];
    
    //发送成功执行
    _inputView.commentTextView.text = @"";
}


#pragma mark - PlayerDelegate 实现ETMSLivePlayerView的代理。
- (void)setCommentText:(NSString *)text{
    _inputView.commentTextView.text = text;
}

@end
