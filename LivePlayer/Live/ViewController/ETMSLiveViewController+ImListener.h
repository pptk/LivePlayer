//
//  ETMSLiveViewController+ImListener.h
//  MastеrsSеriеs
//
//  Created by pptk on 2017/8/8.
//  Copyright © 2017年 8wm. All rights reserved.
//

#import "ETMSLiveViewController.h"
#import "ETMSLiveComModel.h"
@interface ETMSLiveViewController (ImListener)

//- (void)onTextMessage:(ILVLiveTextMessage *)msg;
- (void)onTextMessage:(ETMSLiveComModel *)msg;

@end
