//
//  QMUITextField+HideMenu.m
//  MastеrsSеriеs
//
//  Created by pptk on 2017/8/7.
//  Copyright © 2017年 8wm. All rights reserved.
//

#import "QMUITextField+HideMenu.h"

@implementation QMUITextField (HideMenu)

//隐藏菜单
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}

//拦截长按，隐藏放大镜
-(void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        gestureRecognizer.enabled = NO;
    }
    [super addGestureRecognizer:gestureRecognizer];
}

@end
