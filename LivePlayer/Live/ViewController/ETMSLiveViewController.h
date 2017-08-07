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
@interface ETMSLiveViewController : QMUICommonViewController
{
    ETMSLivePlayerView    *_playerView;
    
    ETMSLiveCommentView   *_msgView;//消息列表TableView
    
    UIView          *_bottomView;//底部输入框父控件
    QMUIButton      *_emoticonBtn;//表情按钮
    QMUIButton      *_sendBtn;//发送按钮
    QMUITextView    *_commentTextView;
    QMUIQQEmotionManager *_qqEmotionManager;//表情框管理
    UIView          *_grayView;//蒙版View   点击之后收起键盘
    
}


@end
