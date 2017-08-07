//
//  ETMSLiveViewController.m
//  MastеrsSеriеs
//
//  Created by pptk on 2017/7/22.
//  Copyright © 2017年 8wm. All rights reserved.
//

#import "ETMSLiveViewController.h"
#import "ETMSLiveViewController+UI.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <Masonry.h>


@interface ETMSLiveViewController ()<UINavigationControllerDelegate>


@end


@implementation ETMSLiveViewController
- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated{
    [super setNavigationItemsIsInEditMode:isInEditMode animated:animated];
    //隐藏返回按钮
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close:)];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.delegate = self;
    [self initEmotion];//初始化表情管理器
    [self initPlayView];//配置视频播放控件的一些参数。
    
}

-(void)initPlayView{
    [_playerView setTitle:@"这是第一趟直播课"];
}

- (void)initSubviews{
    [super initSubviews];
    _msgView = ({
        ETMSLiveCommentView *view = [[ETMSLiveCommentView alloc]init];
        view.backgroundColor = HexRGB(0xf0f0f0);
        [self.view addSubview:view];
        [self.view bringSubviewToFront:_playerView];
        view;
    });
    _playerView = ({
        ETMSLivePlayerView *view = [[ETMSLivePlayerView alloc]init];
        view.backgroundColor = UIColorWhite;
        view.delegate = self;
        [self.view addSubview:view];
        view;
    });
    _bottomView = ({
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = HexRGB(0xe5e5e5);
        view.qmui_borderColor = HexRGB(0xcdcdcd);
        view.qmui_borderWidth = 1;
        view.qmui_borderPosition = QMUIBorderViewPositionTop;
        [self.view addSubview:view];
        view;
    });
    _emoticonBtn = ({
        QMUIButton *btn = [[QMUIButton alloc]init];
        [btn setImage:UIImageMake(@"live_emotion_icon") forState:UIControlStateNormal];
        [btn setImage:UIImageMake(@"live_keyboard_icon") forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(handleEmoticonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:btn];
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
        [_bottomView addSubview:tv];
        tv;
    });
    _sendBtn = ({
        QMUIButton *btn = [[QMUIButton alloc]init];
        [btn setImage:UIImageMake(@"live_comment_send_off") forState:UIControlStateNormal];
        [btn setImage:UIImageMake(@"live_comment_send_on") forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(handleSendEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:btn];
        btn;
    });
    
    _playerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/640*360);
    
    //设置底部控件约束
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
        make.top.equalTo(_bottomView).with.offset(15*kScale);
        make.bottom.equalTo(_bottomView).with.offset(-15*kScale);
        make.left.equalTo(_emoticonBtn.mas_right).with.offset(15*kScale);
        make.right.equalTo(_sendBtn.mas_left).with.offset(-15*kScale);
    }];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.with.offset(0);
    }];
    [_msgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(SCREEN_WIDTH/640*360));
        make.bottom.equalTo(_bottomView.mas_top).with.offset(0);
        make.left.right.mas_equalTo(@0);
    }];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}
#pragma mark - ETMSLiveManager代理方法
-(void)dismiss{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)close:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotate {
    return NO;
}
//控制键盘
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    IQKeyboardManager *keyBoaradManager = [IQKeyboardManager sharedManager];
    keyBoaradManager.enable = NO;
    keyBoaradManager.enableAutoToolbar = NO;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    IQKeyboardManager *keyBoaradManager = [IQKeyboardManager sharedManager];
    keyBoaradManager.enable = YES;
    keyBoaradManager.enableAutoToolbar = YES;
}

//导航栏设置为空的
//-(ETMSNavigationBarStyle)barStyle{
//    return ETMSNavigationBarStyleNoSeparatorLine;
//}
-(UIImage *)navigationBarBackgroundImage{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(36, 36), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

- (void)dealloc{
    [_playerView remove];
    _msgView = nil;
    _bottomView = nil;
    _qqEmotionManager = nil;
    _grayView = nil;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
