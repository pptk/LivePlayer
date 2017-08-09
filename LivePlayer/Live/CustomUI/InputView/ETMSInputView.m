//
//  ETMSInputView.m
//  MastеrsSеriеs
//
//  Created by pptk on 2017/8/9.
//  Copyright © 2017年 8wm. All rights reserved.
//

#import "ETMSInputView.h"
#import <Masonry.h>
//#import <TILLiveSDK/TILLiveSDK.h>

@implementation ETMSInputView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initSubViews];
    }
    return self;
}
- (void)initSubViews{
    self.backgroundColor = HexRGB(0xe5e5e5);
    self.qmui_borderColor = HexRGB(0xcdcdcd);
    self.qmui_borderWidth = 1;
    self.qmui_borderPosition = QMUIBorderViewPositionTop;
    _emoticonBtn = ({
        QMUIButton *btn = [[QMUIButton alloc]init];
        [btn setImage:UIImageMake(@"live_emotion_icon") forState:UIControlStateNormal];
        [btn setImage:UIImageMake(@"live_keyboard_icon") forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(handleEmoticonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        btn;
    });
    _commentTextView = ({
        QMUITextView *tv = [[QMUITextView alloc]init];
        tv.maximumTextLength = 80;//QMUI这个存在一个表情的bug,会崩溃，需要优化。
        tv.autoResizable = YES;
        tv.delegate = self;
        tv.scrollEnabled = NO;
        tv.font = UIFontMake(15);
        tv.placeholder = @"请输入文字";
        tv.layer.masksToBounds = YES;
        tv.layer.cornerRadius = 4;
        tv.layer.borderColor = HexRGB(0xcdcdcd).CGColor;
        tv.layer.borderWidth = .5;
        tv.returnKeyType = UIReturnKeySend;
        [self addSubview:tv];
        tv;
    });
    _sendBtn = ({
        QMUIButton *btn = [[QMUIButton alloc]init];
        [btn setImage:UIImageMake(@"live_comment_send_off") forState:UIControlStateNormal];
        [btn setImage:UIImageMake(@"live_comment_send_on") forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(handleSendEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        btn;
    });
    
    [_emoticonBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(15*kScale));
        make.bottom.mas_equalTo(@(-20*kScale));
        make.width.height.mas_equalTo(@(60*kScale));
    }];
    [_sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(@(-15*kScale));
        make.bottom.mas_equalTo(@(-20*kScale));
        make.height.width.mas_equalTo(@(60*kScale));
    }];
    [_commentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(15*kScale);
        make.bottom.equalTo(self).with.offset(-15*kScale);
        make.left.equalTo(_emoticonBtn.mas_right).with.offset(15*kScale);
        make.right.equalTo(_sendBtn.mas_left).with.offset(-15*kScale);
    }];
    [self keBoard];
}
- (void)handleEmoticonEvent:(QMUIButton *)sender{
    if(sender.selected){
        [_commentTextView becomeFirstResponder];
    }else{
        [self keyBoardWillShow:nil];
    }
}
- (void)handleSendEvent:(id)sender{
    if([[_commentTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
        return;
    }
    if([_delegate respondsToSelector:@selector(sendComment:)]){
        [_delegate sendComment:_commentTextView.text];
    }
}

#pragma mark - 底部控件键盘弹出管理
/**
 表情初始化
 */
- (void)initEmotion{
    _qqEmotionManager = [[QMUIQQEmotionManager alloc]init];
    _qqEmotionManager.boundTextView = _commentTextView;
    _qqEmotionManager.emotionView.qmui_borderPosition = QMUIBorderViewPositionTop;
    [self.superview addSubview:_qqEmotionManager.emotionView];
    if(_qqEmotionManager.emotionView){
        CGRect emotionViewRect = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, kEmotionViewHeight);
        _qqEmotionManager.emotionView.frame = CGRectApplyAffineTransform(emotionViewRect, _qqEmotionManager.emotionView.transform);
    }
    [_qqEmotionManager.emotionView.sendButton addTarget:self action:@selector(handleSendEvent:) forControlEvents:UIControlEventTouchUpInside];
}

//评论输入框的代理
- (BOOL)textViewShouldReturn:(QMUITextView *)textView{
    if([[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
        return NO;
    }
    [self handleSendEvent:nil];
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
        if(!_qqEmotionManager){
            [self initEmotion];
        }
        [UIView animateWithDuration:0.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            [self handleKeyBoardShow:keyboardUserInfo];
        } completion:NULL];
    }
}
- (void)keyBoardWillHide:(QMUIKeyboardUserInfo *)keyboardUserInfo{
    if (keyboardUserInfo) {
        [QMUIKeyboardManager animateWithAnimated:YES keyboardUserInfo:keyboardUserInfo animations:^{
            self.layer.transform = CATransform3DIdentity;
            _qqEmotionManager.emotionView.layer.transform = CATransform3DIdentity;
//            _msgView.layer.transform = CATransform3DIdentity;
        } completion:NULL];
    } else {
        [UIView animateWithDuration:0.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.layer.transform = CATransform3DIdentity;
            _qqEmotionManager.emotionView.layer.transform = CATransform3DIdentity;
//            _msgView.layer.transform = CATransform3DIdentity;
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
    [self.superview insertSubview:_grayView belowSubview:self];
    [self.superview bringSubviewToFront:_qqEmotionManager.emotionView];
    if(keyboardUserInfo){//如果弹出的是键盘
        _emoticonBtn.selected = NO;
        self.layer.transform = CATransform3DMakeTranslation(0, -keyboardUserInfo.endFrame.size.height, 0);
        _qqEmotionManager.emotionView.layer.transform = CATransform3DMakeTranslation(0, -keyboardUserInfo.endFrame.size.height, 0);
//        _msgView.layer.transform = CATransform3DMakeTranslation(0, -distanceFromBottom, 0);
    }else{//如果弹出的是表情
        _emoticonBtn.selected = YES;
        [_commentTextView resignFirstResponder];
        self.layer.transform = CATransform3DMakeTranslation(0, - kEmotionViewHeight, 0);
        _qqEmotionManager.emotionView.layer.transform = CATransform3DMakeTranslation(0, -kEmotionViewHeight, 0);
//        _msgView.layer.transform = CATransform3DMakeTranslation(0, -kEmotionViewHeight, 0);
    }
}
-(void)endEdit:(id)sender{
    [self endEditing:YES];
    [self keyBoardWillHide:nil];
    [_grayView removeFromSuperview];
//    _msgView.layer.transform = CATransform3DIdentity;
}


@end
