//
//  ETMSLiveViewController.h
//  MastеrsSеriеs
//
//  Created by pptk on 2017/7/22.
//  Copyright © 2017年 8wm. All rights reserved.
//
#define kEmotionViewHeight 232

#import "ETMSLiveCommentView.h"
#import "ETMSLivePlayerView.h"
#import "ETMSInputView.h"

@interface ETMSLiveViewController : QMUICommonViewController
{
    ETMSLivePlayerView    *_playView;
    
    ETMSLiveCommentView   *_msgView;//消息列表TableView
    
    ETMSInputView         *_inputView;//底部输入框
    
}


@end
