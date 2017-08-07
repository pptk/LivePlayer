//
//  ETMSLiveMeidaView.h
//  MastеrsSеriеs
//
//  Created by pptk on 2017/8/3.
//  Copyright © 2017年 8wm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETMSLiveCommentView.h"

@protocol MediaDelegate <NSObject>

- (void)setScreenBtnStatus:(BOOL)status;//改变屏幕方向之后调用

@end

@interface ETMSLiveMediaView : UIView

@property(nonatomic, assign) BOOL isFullScreen;//屏幕状态记录
@property(nonatomic, assign) BOOL isEditing;//是否正在编辑状态（键盘显示）
@property (nonatomic, assign) BOOL didEnterBackground;//是否进入后台
@property(nonatomic, weak) id<MediaDelegate> delegate;

@property(nonatomic, weak) UIView *parentView;//父控件，旋转的时候使用,由于上面承载了其他控件，所以必须用父控件旋转
@property(nonatomic, weak) UIView *grandpaView;//父控件的控件，还原的时候使用

- (void)remove;//清除
- (void)handleFullScreen;//手动调用屏幕旋转

- (void)stopDanmaku;//停止弹幕
- (void)addDanmaku:(ETMSLiveComModel *)model;//发送弹幕

@end
