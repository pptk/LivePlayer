//
//  ETMSInputView.h
//  MastеrsSеriеs
//
//  Created by pptk on 2017/8/9.
//  Copyright © 2017年 8wm. All rights reserved.
//  输入框
#define kEmotionViewHeight 232

#import <UIKit/UIKit.h>
#import <QMUIKit.h>

@protocol InputDelegate <NSObject>

- (void)sendComment:(NSString *)text;

@end

@interface ETMSInputView : UIView<QMUITextViewDelegate>

@property(nonatomic, weak) id<InputDelegate> delegate;

@property(nonatomic, strong) QMUIButton *emoticonBtn;//表情按钮
@property(nonatomic, strong) QMUIButton *sendBtn;//发送按钮
@property(nonatomic, strong) QMUITextView *commentTextView;//评论
@property(nonatomic, strong) QMUIQQEmotionManager *qqEmotionManager;//表情框管理
@property(nonatomic, strong) UIView *grayView;

@end
