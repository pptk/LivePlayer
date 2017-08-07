//
//  ETMSLiveMeidaView.m
//  MastеrsSеriеs
//
//  Created by pptk on 2017/8/3.
//  Copyright © 2017年 8wm. All rights reserved.
//

#import "ETMSLiveMediaView.h"
#import "AppDelegate.h"
#import "HJDanmakuView.h"
#import "ETMSDanmakuCell.h"
#import <Masonry.h>

@interface ETMSLiveMediaView()<HJDanmakuViewDelegate,HJDanmakuViewDateSource>

@property(nonatomic, strong) HJDanmakuView *danmakuView;

@end
@implementation ETMSLiveMediaView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self addNotifications];
        [self addObserver:self forKeyPath:@"isFullScreen" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"isFullScreen"]){//屏幕变动之后需要做的操作
        if([_delegate respondsToSelector:@selector(setScreenBtnStatus:)]){
            [_delegate setScreenBtnStatus:_isFullScreen];
        }
        if(!_isFullScreen){//如果不是全屏。
            [_danmakuView stop];
            [_danmakuView removeFromSuperview];
            _danmakuView = nil;
            //把键盘归位置
            for(UIWindow *window in [UIApplication sharedApplication].windows){
                if([window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")] || [window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]){
                    window.transform = CGAffineTransformIdentity;
                    window.bounds =CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT);
                    window.center = CGPointMake(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5);
                }
            }
        }else{//如果是全屏
            if(!_danmakuView){
                HJDanmakuConfiguration *config = [[HJDanmakuConfiguration alloc]initWithDanmakuMode:HJDanmakuModeLive];
                _danmakuView = [[HJDanmakuView alloc]initWithFrame:self.bounds configuration:config];
                _danmakuView.dataSource = self;
                _danmakuView.delegate = self;
                [self.danmakuView registerClass:[ETMSDanmakuCell class] forCellReuseIdentifier:@"cell"];
                self.danmakuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            }
            [self addSubview:_danmakuView];
            
            if (!self.danmakuView.isPrepared) {
                [self.danmakuView prepareDanmakus:nil];
            }
        }
    }
}


- (void)addNotifications{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStatusBarOrientationChange)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}
//屏幕方向发生变化通知
- (void)onDeviceOrientationChange {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown ) { return; }
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            
        }
            break;
        case UIInterfaceOrientationPortrait:
        {
            if (self.isFullScreen) {
                [self toOrientation:UIInterfaceOrientationPortrait];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        {
            if (self.isFullScreen == NO) {
                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
                self.isFullScreen = YES;
            } else {
                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeRight:
        {
            if (self.isFullScreen == NO) {
                [self toOrientation:UIInterfaceOrientationLandscapeRight];
                self.isFullScreen = YES;
            } else {
                [self toOrientation:UIInterfaceOrientationLandscapeRight];
            }
        }
            break;
        default:
            break;
    }
}
// 状态条变化通知（在前台播放才去处理）
- (void)onStatusBarOrientationChange {
    if (!self.didEnterBackground) {
        // 获取到当前状态条的方向
        UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (currentOrientation == UIInterfaceOrientationPortrait) {
            [self setOrientationPortraitConstraint];
        } else {
            if (currentOrientation == UIInterfaceOrientationLandscapeRight) {
                [self toOrientation:UIInterfaceOrientationLandscapeRight];
            } else if (currentOrientation == UIDeviceOrientationLandscapeLeft){
                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
            }
        }
    }
}
- (void)setOrientationPortraitConstraint{
    if(_grandpaView){
        [_parentView removeFromSuperview];
        [_grandpaView addSubview:_parentView];
        [_parentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsZero);
        }];
    }
    [self toOrientation:UIInterfaceOrientationPortrait];
    self.isFullScreen = NO;
}

- (void)toOrientation:(UIInterfaceOrientation)orientation {
    // 获取到当前状态条的方向
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    // 判断如果当前方向和要旋转的方向一致,那么不做任何操作
    if (currentOrientation == orientation) { return; }
    if (orientation != UIInterfaceOrientationPortrait) {//横屏
        if (currentOrientation == UIInterfaceOrientationPortrait) {
            [_parentView removeFromSuperview];
            [[UIApplication sharedApplication].keyWindow addSubview:_parentView];
            [_parentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(SCREEN_HEIGHT));
                make.height.equalTo(@(SCREEN_WIDTH));
                make.center.equalTo([UIApplication sharedApplication].keyWindow);
            }];
        }
    }
    // iOS6.0之后,设置状态条的方法能使用的前提是shouldAutorotate为NO,也就是说这个视图控制器内,旋转要关掉;
    // 也就是说在实现这个方法的时候-(BOOL)shouldAutorotate返回值要为NO
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    // 获取旋转状态条需要的时间:
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    // 更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
    // 给你的播放视频的view视图设置旋转
    self.parentView.transform = CGAffineTransformIdentity;
    self.parentView.transform = [self getTransformRotationAngle];
    // 开始旋转
    [UIView commitAnimations];
}
/**
 * 获取变换的旋转角度
 *
 * @return 角度
 */
- (CGAffineTransform)getTransformRotationAngle {
    // 状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    // 根据要进行旋转的方向来计算旋转的角度
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if(orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

//手动调用旋转
- (void)handleFullScreen{
    if(_isFullScreen){
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
        self.isFullScreen = NO;
        return;
    }else{
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationLandscapeRight) {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        } else {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        }
        self.isFullScreen = YES;
    }
}
/**
 *  屏幕转屏
 *
 *  @param orientation 屏幕方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
        [self setOrientationLandscapeConstraint:orientation];
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
        [self setOrientationPortraitConstraint];
    }
}
/**
 *  设置横屏的约束
 */
- (void)setOrientationLandscapeConstraint:(UIInterfaceOrientation)orientation {
    [self toOrientation:orientation];
    self.isFullScreen = YES;
}

/**
 显示键盘
 */
- (void)transKeyBoard{
    for(UIWindow *window in [UIApplication sharedApplication].windows){
        if([window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")] || [window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]){
            window.transform = [self getTransformRotationAngle];
            window.bounds =CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
            window.center = CGPointMake([[UIScreen mainScreen] bounds].size.height*0.5f,[[UIScreen mainScreen] bounds].size.width*0.5f);
        }
    }
}
- (void)resetKeyBoard{
    for(UIWindow *window in [UIApplication sharedApplication].windows){
        if([window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")] || [window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]){
            window.transform = [self getTransformRotationAngle];
            window.bounds =CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
            window.center = CGPointMake([[UIScreen mainScreen] bounds].size.width*0.5f,[[UIScreen mainScreen] bounds].size.height*0.5f);
        }
    }
}
- (void)setIsEditing:(BOOL)isEditing{
    if(isEditing)
        [self transKeyBoard];
    else
        [self resetKeyBoard];
}

#pragma mark - 弹幕
- (void)stopDanmaku{
    [_danmakuView stop];
    [_danmakuView removeFromSuperview];
    _danmakuView = nil;
}
- (void)addDanmaku:(ETMSLiveComModel *)model{
    [self.danmakuView sendDanmaku:model forceRender:YES];
}

#pragma mark - delegate

- (void)prepareCompletedWithDanmakuView:(HJDanmakuView *)danmakuView {
    [self.danmakuView play];
}

- (BOOL)danmakuView:(HJDanmakuView *)danmakuView shouldSelectCell:(HJDanmakuCell *)cell danmaku:(HJDanmakuModel *)danmaku {
    return danmaku.danmakuType == HJDanmakuTypeLR;
}

- (void)danmakuView:(HJDanmakuView *)danmakuView didSelectCell:(HJDanmakuCell *)cell danmaku:(HJDanmakuModel *)danmaku {
    NSLog(@"select=> %@", cell.textLabel.text);
}

#pragma mark - dataSource

- (CGFloat)danmakuView:(HJDanmakuView *)danmakuView widthForDanmaku:(HJDanmakuModel *)danmaku {
    ETMSLiveComModel *model = (ETMSLiveComModel *)danmaku;
    return [model.comment sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}].width + 1.0f;
}

- (HJDanmakuCell *)danmakuView:(HJDanmakuView *)danmakuView cellForDanmaku:(HJDanmakuModel *)danmaku {
    ETMSLiveComModel *model = (ETMSLiveComModel *)danmaku;
    ETMSDanmakuCell *cell = [danmakuView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = HJDanmakuCellSelectionStyleDefault;
    cell.alpha = 1;
//    if ([model.userId isEqualToString:userDefaults(@"userId")]) {
//        cell.zIndex = 30;
//        cell.layer.borderWidth = 0.5;
//        cell.layer.borderColor = [UIColor redColor].CGColor;
//    }
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = UIColorRed;
    cell.textLabel.text = model.comment;
    return cell;
}



- (void)dealloc{
    [self remove];
}
-(void)remove{
    self.parentView = nil;
    self.grandpaView = nil;
    self.delegate = nil;
    [self.danmakuView stop];
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

@end
