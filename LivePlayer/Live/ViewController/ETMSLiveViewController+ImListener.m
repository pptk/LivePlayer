//
//  ETMSLiveViewController+ImListener.m
//  MastеrsSеriеs
//
//  Created by pptk on 2017/8/8.
//  Copyright © 2017年 8wm. All rights reserved.
//

#import "ETMSLiveViewController+ImListener.h"

@implementation ETMSLiveViewController (ImListener)

//文本消息回调
- (void)onTextMessage:(ETMSLiveComModel *)model{
    [_msgView addComment:model];
    [_playView sendDanmaku:model];//发送弹幕，会根据是否全屏和显示弹幕自动过滤
}

- (void)onCustomMessage:(id)msg{
    //暂不处理
    NSLog(@"handle custom message = %@",msg);
}


@end
