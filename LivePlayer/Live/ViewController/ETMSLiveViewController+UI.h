//
//  ETMSLiveViewController+UI.h
//  MastеrsSеriеs
//
//  Created by pptk on 2017/7/24.
//  Copyright © 2017年 8wm. All rights reserved.
//  主要负责消息列表视图的控制处理

#import "ETMSLiveViewController.h"

@interface ETMSLiveViewController (UI)<PlayerDelegate,QMUIKeyboardManagerDelegate,QMUITextViewDelegate>

//发送消息相关的方法
- (void)initEmotion;

- (void)handleEmoticonEvent:(QMUIButton *)sender;
- (void)handleSendEvent:(QMUIButton *)sender;

@end
