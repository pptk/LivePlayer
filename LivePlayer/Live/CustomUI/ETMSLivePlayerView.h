//
//  ETMSLivePlayerView.h
//  MastеrsSеriеs
//
//  Created by pptk on 2017/7/28.
//  Copyright © 2017年 8wm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETMSLiveCommentView.h"
#import "ETMSLiveComModel.h"

@protocol PlayerDelegate <NSObject>

- (void)setCommentText:(NSString *)text;//把 全屏输入框的文本 导入到 竖屏的输入框

@end


@interface ETMSLivePlayerView : UIView

@property(nonatomic, assign) BOOL enterBackground;//进入后台
@property(nonatomic, weak) id<PlayerDelegate> delegate;

- (void)sendDanmaku:(ETMSLiveComModel *)model;//发送弹幕
- (void)setGusetNumber:(NSString *)number;//设置客人数
- (void)setTitle:(NSString *)title;//设置标题
- (void)remove;

@end
