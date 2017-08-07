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

@implementation ETMSLiveViewController (UI)

/**
 点击表情按钮
 
 @param sender 表情按钮
 */
- (void)handleEmoticonEvent:(QMUIButton *)sender{
    if(sender.selected){
        [_commentTextView becomeFirstResponder];
    }else{
        [self keyBoardWillShow:nil];
    }
}

/**
 点击发送按钮
 
 @param sender 发送按钮
 */
- (void)handleSendEvent:(QMUIButton *)sender{
    if([[_commentTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
        return;
    }
    [self sendText:_commentTextView.text];
}
- (void)sendText:(NSString *)text{
    _commentTextView.text = @"";
    [self endEdit:nil];
    ETMSLiveComModel *model = [[ETMSLiveComModel alloc]init];
    model.userId = @"";
    model.head = @"head_image";
    model.name = @"张三";
    model.comment = text;
    [_msgView addComment:model];
}

#pragma mark - PlayerDelegate 实现ETMSLivePlayerView的代理。
- (void)setCommentText:(NSString *)text{
    _commentTextView.text = text;
}



#pragma mark - 底部控件键盘弹出管理
/**
 表情初始化
 */
- (void)initEmotion{
    _qqEmotionManager = [[QMUIQQEmotionManager alloc]init];
    _qqEmotionManager.boundTextView = _commentTextView;
    _qqEmotionManager.emotionView.qmui_borderPosition = QMUIBorderViewPositionTop;
    [self.view addSubview:_qqEmotionManager.emotionView];
    if(_qqEmotionManager.emotionView){
        CGRect emotionViewRect = CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), kEmotionViewHeight);
        _qqEmotionManager.emotionView.frame = CGRectApplyAffineTransform(emotionViewRect, _qqEmotionManager.emotionView.transform);
    }
    [_qqEmotionManager.emotionView.sendButton addTarget:self action:@selector(handleSendEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self keBoard];
}

//评论输入框的代理
- (BOOL)textViewShouldReturn:(QMUITextView *)textView{
    if([[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
        return NO;
    }
    [self sendText:textView.text];
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{//调整光标，以便找到正确的插入表情位置
    _qqEmotionManager.selectedRangeForBoundTextInput = textView.selectedRange;
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    if([[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){//如果为空
        _sendBtn.selected = NO;
    }else{
        _sendBtn.selected = YES;
    }
    CGFloat width = CGRectGetWidth(textView.frame);
    CGFloat height = CGRectGetHeight(textView.frame);
    CGSize newSize = [textView sizeThatFits:CGSizeMake(width,MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmax(width, newSize.width), fmax(height, newSize.height));
    textView.frame= newFrame;
}

#pragma mark - 键盘管理
- (void)keBoard{
    WS(weakSelf)
    _commentTextView.qmui_keyboardWillShowNotificationBlock = ^(QMUIKeyboardUserInfo *keyboardUserInfo) {
        [weakSelf keyBoardWillShow:keyboardUserInfo];
    };
    _commentTextView.qmui_keyboardWillHideNotificationBlock = ^(QMUIKeyboardUserInfo *keyboardUserInfo) {
        [weakSelf keyBoardWillHide:keyboardUserInfo];
    };
}
- (void)keyBoardWillShow:(QMUIKeyboardUserInfo *)keyboardUserInfo{
    if (keyboardUserInfo) {
        [QMUIKeyboardManager animateWithAnimated:YES keyboardUserInfo:keyboardUserInfo animations:^{
            [self handleKeyBoardShow:keyboardUserInfo];
        } completion:NULL];
    } else {
        [UIView animateWithDuration:0.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            [self handleKeyBoardShow:keyboardUserInfo];
        } completion:NULL];
    }
}
- (void)keyBoardWillHide:(QMUIKeyboardUserInfo *)keyboardUserInfo{
    if (keyboardUserInfo) {
        [QMUIKeyboardManager animateWithAnimated:YES keyboardUserInfo:keyboardUserInfo animations:^{
            _bottomView.layer.transform = CATransform3DIdentity;
            _qqEmotionManager.emotionView.layer.transform = CATransform3DIdentity;
            _msgView.layer.transform = CATransform3DIdentity;
        } completion:NULL];
    } else {
        [UIView animateWithDuration:0.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            _bottomView.layer.transform = CATransform3DIdentity;
            _qqEmotionManager.emotionView.layer.transform = CATransform3DIdentity;
            _msgView.layer.transform = CATransform3DIdentity;
        } completion:NULL];
    }
}
//显示键盘的操作
- (void)handleKeyBoardShow:(QMUIKeyboardUserInfo *)keyboardUserInfo{
    if(!_grayView){
        _grayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _grayView.backgroundColor = UIColorClear;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEdit:)];
        [_grayView addGestureRecognizer:tap];
    }
    [self.view addSubview:_grayView];
    [self.view bringSubviewToFront:_qqEmotionManager.emotionView];
    [self.view bringSubviewToFront:_bottomView];
    if(keyboardUserInfo){//如果弹出的是键盘
        _emoticonBtn.selected = NO;
        CGFloat distanceFromBottom = [QMUIKeyboardManager distanceFromMinYToBottomInView:self.view keyboardRect:keyboardUserInfo.endFrame];
        _bottomView.layer.transform = CATransform3DMakeTranslation(0, - distanceFromBottom, 0);
        _qqEmotionManager.emotionView.layer.transform = CATransform3DMakeTranslation(0, - distanceFromBottom, 0);
        _msgView.layer.transform = CATransform3DMakeTranslation(0, -distanceFromBottom, 0);
    }else{//如果弹出的是表情
        _emoticonBtn.selected = YES;
        [_commentTextView resignFirstResponder];
        _bottomView.layer.transform = CATransform3DMakeTranslation(0, - kEmotionViewHeight, 0);
        _qqEmotionManager.emotionView.layer.transform = CATransform3DMakeTranslation(0, -kEmotionViewHeight, 0);
        _msgView.layer.transform = CATransform3DMakeTranslation(0, -kEmotionViewHeight, 0);
    }
}
-(void)endEdit:(id)sender{
    [self.view endEditing:YES];
    [self keyBoardWillHide:nil];
    [_grayView removeFromSuperview];
    _msgView.layer.transform = CATransform3DIdentity;
}

@end
