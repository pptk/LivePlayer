//
//  ETMSLivePlayerView.m
//  MastеrsSеriеs
//
//  Created by pptk on 2017/7/28.
//  Copyright © 2017年 8wm. All rights reserved.
//
#define CHANGE_VERTICALSCREEN @"home_video_back_fullScreen_btn"
#define CHANGE_FULLSCREEN @"home_video_fullScreen_btn"

#import "ETMSLivePlayerView.h"
#import <Masonry.h>

#import <ReactiveObjC.h>
#import "ETMSLiveMediaView.h"
#import "NSTimer+JKAddition.h"
#import "NSTimer+JKBlocks.h"
#import "QMUITextField+HideMenu.h"
#import "ETMSLiveComModel.h"

@interface ETMSLivePlayerView()<MediaDelegate,QMUITextFieldDelegate>

@property(nonatomic, strong) UIView *topView;//顶部阴影
@property(nonatomic, strong) UIView *bottomView;//底部阴影


@property(nonatomic, strong) UIView *contentView;

@property(nonatomic, strong) ETMSLiveMediaView *mediaView;//媒体View
@property(nonatomic, strong) QMUIButton *guestNumBtn;//观众数
@property(nonatomic, strong) QMUIButton *changeScreenBtn;//全屏按钮
@property(nonatomic, strong) QMUILabel *titleLabel;//标题
@property(nonatomic, strong) QMUIButton *barrageBtn;//是否开弹幕按钮
@property(nonatomic, strong) QMUIButton *commentBtn;//评论按钮
@property(nonatomic, strong) QMUIButton *backBtn;//返回按钮（横屏的时候使用）
@property(nonatomic, strong) QMUIButton *shareBtn;//分享按钮

@property(nonatomic, assign) BOOL isShowShadow;//是否显示阴影
@property(nonatomic, strong) NSTimer *countDown;//倒计时

@property(nonatomic, strong) UIView *commentView;//评论父控件
@property(nonatomic, strong) QMUITextField *commentTextField;//评论输入框
@property(nonatomic, strong) QMUIButton *sendBtn;//发送评论按钮
@property(nonatomic, strong) UIView *grayView;//遮罩view

/* 视图层级
 self{
 contentView{
 mediaView,
 
 //这个View主要掌控下面这些子View的逻辑
 topView{
 titleLabel,
 shareBtn
 },
 bottomView{
 guestNumBtn，
 changeScreenBtn，
 },
 commentBtn,
 barrageBtn
 }
 }
 */
@end

@implementation ETMSLivePlayerView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initSubViews];
        [self kvoKeyBoard];
        [self showShadow];
        [self initTap];
    }
    return self;
}
- (void)initSubViews{
    _contentView = ({
        UIView *view = [UIView new];
        [self addSubview:view];
        view;
    });
    _mediaView = ({
        ETMSLiveMediaView *mediaView = [[ETMSLiveMediaView alloc]init];
        mediaView.delegate = self;
        mediaView.parentView = _contentView;
        mediaView.grandpaView = self;
        mediaView.backgroundColor = UIColorYellow;
        [_contentView addSubview:mediaView];
        mediaView;
    });
    _titleLabel = ({
        QMUILabel *label = [[QMUILabel alloc]init];
        [label setFont:UIFontMake(17)];
        [label setTextColor:UIColorWhite];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.text = @"";
        label;
    });
    _shareBtn = ({
        QMUIButton *btn = [[QMUIButton alloc]init];
        [btn setImage:UIImageMake(CHANGE_VERTICALSCREEN) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(handleShareClick:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    _backBtn = ({
        QMUIButton *btn = [[QMUIButton alloc]init];
        [btn addTarget:self action:@selector(handleBackClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:UIImageMake(@"navBar_icon_back_nml") forState:UIControlStateNormal];
        btn.hidden = YES;
        btn;
    });
    
    _topView = ({
        UIView *view = [[UIView alloc]init];
        [view addSubview:_titleLabel];
        [view addSubview:_shareBtn];
        [view addSubview:_backBtn];
        view.layer.contents = (__bridge id)UIImageMake(@"navBar_bg_nml").CGImage;
        [_contentView addSubview:view];
        view;
    });
    _bottomView = ({
        UIView *view = [[UIView alloc]init];
        view.layer.contents = (__bridge id)[UIImageMake(@"navBar_bg_nml") qmui_imageWithOrientation:UIImageOrientationDown].CGImage;
        [_contentView addSubview:view];
        view;
    });
    _guestNumBtn = ({
        QMUIButton *btn = [[QMUIButton alloc]init];
        btn.imagePosition = QMUIButtonImagePositionLeft;
        [btn.titleLabel setFont:UIFontMake(13)];
        [btn setTitle:@"1" forState:UIControlStateNormal];
        [btn setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [btn setImage:UIImageMake(@"live_online_member") forState:UIControlStateNormal];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_bottomView addSubview:btn];
        btn;
    });
    _changeScreenBtn = ({
        QMUIButton *btn = [[QMUIButton alloc]init];
        [btn setImage:UIImageMake(CHANGE_VERTICALSCREEN) forState:UIControlStateSelected];
        [btn setImage:UIImageMake(CHANGE_FULLSCREEN) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(handleChangeScreenClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:btn];
        btn;
    });
    
    //横屏才会显示的按钮
    _barrageBtn = ({
        QMUIButton *btn = [[QMUIButton alloc]init];
        //默认开弹幕，btn selected状态为关弹幕
        [btn setImage:UIImageMake(CHANGE_FULLSCREEN) forState:UIControlStateNormal];
        [btn setImage:UIImageMake(CHANGE_VERTICALSCREEN) forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(handleBarrageClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.hidden = YES;
        [_contentView addSubview:btn];
        btn;
    });
    _commentBtn = ({
        QMUIButton *btn = [[QMUIButton alloc]init];
        //默认开弹幕，btn selected状态为关弹幕
        [btn setImage:UIImageMake(@"store_comment_addphoto_btn") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(handleCommentClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.hidden = YES;
        [_contentView addSubview:btn];
        btn;
    });
    
    //评论控件
    _commentTextField = ({
        QMUITextField *textField = [[QMUITextField alloc]init];
        textField.placeholder = @"请输入文字";
        textField.maximumTextLength = 80;
        textField.layer.masksToBounds = YES;
        textField.layer.cornerRadius = 4;
        textField.layer.borderColor = HexRGB(0xcdcdcd).CGColor;
        textField.layer.borderWidth = .5;
        textField.returnKeyType = UIReturnKeySend;
        textField.backgroundColor = [UIColor whiteColor];
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        textField.delegate = self;
        textField;
    });
    _sendBtn = ({
        QMUIButton *btn = [[QMUIButton alloc]init];
        [btn setImage:UIImageMake(@"live_comment_send_off") forState:UIControlStateNormal];
        [btn setImage:UIImageMake(@"live_comment_send_on") forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(handleSendComment:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    _commentView = ({
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = HexRGB(0xe5e5e5);
        view.qmui_borderColor = HexRGB(0xcdcdcd);
        view.qmui_borderWidth = 1;
        view.qmui_borderPosition = QMUIBorderViewPositionTop;
        [view addSubview:_commentTextField];
        [view addSubview:_sendBtn];
        view.hidden = YES;
        [_contentView addSubview:view];
        view;
    });
    WS(weakSelf)
    //子控件约束
    [_sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15*kScale);
        make.top.mas_equalTo(12*kScale);
        make.bottom.mas_equalTo(-12*kScale);
        make.width.height.mas_equalTo(60*kScale);
    }];
    [_commentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15*kScale);
        make.centerY.mas_equalTo(weakSelf.commentView.mas_centerY);
        make.right.equalTo(weakSelf.sendBtn.mas_left).with.offset(-15*kScale);
        make.top.mas_equalTo(10*kScale);
        make.bottom.mas_equalTo(-10*kScale);
    }];
    [_commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    //约束
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [_mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(150*kScale);
        make.top.mas_equalTo(40*kScale);
        make.height.mas_equalTo(88*kScale);
        make.right.mas_equalTo(-150*kScale);
    }];
    [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(40*kScale);
        make.width.height.mas_equalTo(88*kScale);
    }];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.height.mas_equalTo(88*kScale);
        make.top.mas_equalTo(40*kScale);
    }];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(NavigationContentTop);
    }];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(NavigationContentTop);
    }];
    [_changeScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.bottomView.mas_right).offset(-40*kScale);
        make.centerY.equalTo(weakSelf.bottomView.mas_centerY).offset(20*kScale);
        make.width.height.mas_equalTo(60*kScale);
    }];
    [_guestNumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.changeScreenBtn.mas_left).offset(-20*kScale);
        make.centerY.equalTo(weakSelf.bottomView.mas_centerY).offset(20*kScale);
        make.height.mas_equalTo(40*kScale);
        make.width.mas_equalTo(100);
    }];
    [_barrageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(80*kScale);
        make.right.equalTo(weakSelf.contentView.mas_right).offset(-20*kScale);
        make.centerY.equalTo(weakSelf.contentView.mas_centerY).offset(-50*kScale);
    }];
    [_commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(80*kScale);
        make.right.equalTo(weakSelf.contentView.mas_right).offset(-20*kScale);
        make.centerY.equalTo(weakSelf.contentView.mas_centerY).offset(50*kScale);
    }];
}

#pragma mark - mark Media Delegate
- (void)setScreenBtnStatus:(BOOL)status{//status的值 即 isFullScreen
    if(!status){//不是全屏
        _commentBtn.hidden = YES;
        _barrageBtn.hidden = YES;
        _backBtn.hidden = YES;
        [_commentTextField resignFirstResponder];
        _commentView.hidden = YES;
        if([_commentTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] && [_delegate respondsToSelector:@selector(setCommentText:)]){
            [_delegate setCommentText:_commentTextField.text];
        }
    }else{//是全屏
        _commentBtn.hidden = NO;
        _barrageBtn.hidden = NO;
        _backBtn.hidden = NO;
    }
    _changeScreenBtn.selected = status;
}

#pragma mark - Click 操作
/**
 横竖屏
 
 @param btn 设置横竖屏按钮
 */
- (void)handleChangeScreenClick:(id)sender{
    [_mediaView handleFullScreen];
}
- (void)handleBackClick:(id)sender{
    [self handleChangeScreenClick:nil];
}

/**
 开关弹幕
 
 @param btn 开关按钮
 */
- (void)handleBarrageClick:(QMUIButton *)btn{
    if(btn.selected){
        NSLog(@"关弹幕");
    }else{
        NSLog(@"开弹幕");
    }
    btn.selected = !btn.selected;
}

/**
 全屏的评论操作
 
 @param btn 评论
 */
- (void)handleSendComment:(QMUIButton *)btn{//发送评论
    if([[_commentTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){//如果为空
        _sendBtn.selected = NO;
        return;
    }else{//发送操作
        //本地测试所用，正式删除，放开下面注释的代码
        [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
            ETMSLiveComModel *model = [[ETMSLiveComModel alloc]init];
            model.comment = [NSString stringWithFormat:@"%@小胜多负少的发顺丰大是大非%d",_commentTextField.text,arc4random()%93432423];
            model.userId = @"111";
            [self sendDanmaku:model];
        }];
        
        if([_delegate respondsToSelector:@selector(sendCommentText:)]){
            [_delegate sendCommentText:_commentTextField.text];
        }
        [_commentTextField resignFirstResponder];
        _commentTextField.text = @"";
        _commentView.hidden = YES;
    }
}

- (void)handleCommentClick:(id)sender{//点击评论按钮
    if(_commentView.hidden){
        _commentView.hidden = !_commentView.hidden;
        [_commentTextField becomeFirstResponder];
        [self hideShadow];
    }else{
        _commentView.hidden = !_commentView.hidden;
        [_commentTextField resignFirstResponder];
    }
}

- (void)sendDanmaku:(ETMSLiveComModel *)model{//发送弹幕
    if(!_mediaView.isFullScreen || _barrageBtn.selected){//如果不是全屏,或已关闭弹幕
        return;
    }
//    ILVLiveTextMessage *msg = [[ILVLiveTextMessage alloc]init];
//    msg.type = ILVLIVE_IMTYPE_GROUP;
//    msg.text = model.comment;
    [_mediaView addDanmaku:model];
}



- (void)textFieldDidChange:(QMUITextField *)textField{
    if([[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){//如果为空
        _sendBtn.selected = NO;
    }else{
        _sendBtn.selected = YES;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
        return NO;
    }
    [self handleSendComment:nil];
    return YES;
}




- (void)kvoKeyBoard{
    WS(weakSelf)
    _commentTextField.qmui_keyboardWillShowNotificationBlock = ^(QMUIKeyboardUserInfo *keyboardUserInfo) {
        if(!weakSelf.grayView){
            weakSelf.grayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            weakSelf.grayView.backgroundColor = UIColorClear;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:weakSelf action:@selector(handleCommentClick:)];
            [weakSelf.grayView addGestureRecognizer:tap];
        }
        [weakSelf.contentView insertSubview:weakSelf.grayView belowSubview:weakSelf.commentView];
        weakSelf.mediaView.isEditing = YES;//告诉MediaView,处于全屏编辑状态，旋转好键盘。
        
        CGFloat distanceFromBottom = keyboardUserInfo.endFrame.size.width;
        
        [weakSelf.commentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_offset(-distanceFromBottom);
        }];
    };
    _commentTextField.qmui_keyboardWillHideNotificationBlock = ^(QMUIKeyboardUserInfo *keyboardUserInfo) {
        [weakSelf.grayView removeFromSuperview];
        weakSelf.mediaView.isEditing = NO;//告诉MediaView,处于全屏编辑状态，还原键盘。
        [weakSelf.commentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_offset(0);
        }];
    };
}
/**
  分享
 
 @param sender
 */
- (void)handleShareClick:(id)sender{
    
}

#pragma mark - set 操作
/**
 设置观众人数
 
 @param number 人数
 */
- (void)setGusetNumber:(NSString *)number{
    [_guestNumBtn setTitle:number forState:UIControlStateNormal];
}

/**
 设置课程标题
 
 @param title 标题
 */
- (void)setTitle:(NSString *)title{
    _titleLabel.text = title;
}

- (void)remove{
    [_mediaView remove];
    _mediaView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 控制title和bottom view的隐藏和显示
- (void)initTap{
    //默认是显示的
    _isShowShadow = YES;
    UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
    [_contentView addGestureRecognizer:tap];
    WS(weakSelf)
    [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @synchronized(weakSelf)
        {
            if(weakSelf.isShowShadow){
                [self hideShadow];
            }else{
                [self showShadow];
            }
        }
    }];
    //其他手势操作待定
}
- (void)showShadow{//显示阴影
    @synchronized (self) {
        _isShowShadow = !_isShowShadow;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        _topView.transform = CGAffineTransformIdentity;
        _bottomView.transform = CGAffineTransformIdentity;
        _topView.alpha = 1;
        _bottomView.alpha = 1;
        [UIView commitAnimations];
        if(_countDown){
            [_countDown invalidate];
            _countDown = nil;
        }
        _countDown = [NSTimer jk_scheduledTimerWithTimeInterval:8 block:^{
            [self hideShadow];
            [_countDown invalidate];
            _countDown = nil;
        } repeats:NO];
    }
}
- (void)hideShadow{//隐藏阴影
    @synchronized (self) {
        _isShowShadow = !_isShowShadow;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        _topView.transform = CGAffineTransformMakeTranslation(0, -NavigationContentTop);
        _bottomView.transform = CGAffineTransformMakeTranslation(0, NavigationContentTop);
        _topView.alpha = 0;
        _bottomView.alpha = 0;
        [UIView commitAnimations];
    }
}
- (void)dealloc{
    [self remove];
}


@end
