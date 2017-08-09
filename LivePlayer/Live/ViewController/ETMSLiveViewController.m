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
#import "ETMSLiveViewController+ImListener.h"


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
    [self initPlayView];//配置视频播放控件的一些参数。
}

-(void)initPlayView{
    [_playView setTitle:@"这是第一趟直播课"];
}

- (void)initSubviews{
    [super initSubviews];
    _playView = ({
        ETMSLivePlayerView *view = [[ETMSLivePlayerView alloc]init];
        view.backgroundColor = UIColorWhite;
        view.delegate = self;
        [self.view addSubview:view];
        view;
    });
    _msgView = ({
        ETMSLiveCommentView *view = [[ETMSLiveCommentView alloc]init];
        view.backgroundColor = HexRGB(0xf0f0f0);
        [self.view addSubview:view];
        [self.view bringSubviewToFront:_playView];
        view;
    });
    _inputView = ({
        ETMSInputView *view = [[ETMSInputView alloc]init];
        view.delegate = self;
        [self.view addSubview:view];
        view;
    });
    _playView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/640*360);
    //约束
    [_inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.with.offset(0);
    }];
    [_msgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(SCREEN_WIDTH/640*360-NavigationContentTop));
        make.bottom.equalTo(_inputView.mas_top).with.offset(0);
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
    [_playView remove];
    _msgView = nil;
    _inputView = nil;
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
