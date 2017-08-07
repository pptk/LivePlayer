//
//  ETMSLiveCommentView.m
//  MastеrsSеriеs
//
//  Created by pptk on 2017/7/26.
//  Copyright © 2017年 8wm. All rights reserved.
//

#import "ETMSLiveCommentView.h"
#import "ETMSLiveCommentTableViewCell.h"
#import <Masonry.h>
@interface ETMSLiveCommentView()<QMUITableViewDelegate,QMUITableViewDataSource>

@end

@implementation ETMSLiveCommentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _msgTableView = [[QMUITableView alloc]init];
        _msgTableView.delegate = self;
        _msgTableView.dataSource = self;
        _msgTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _msgTableView.showsHorizontalScrollIndicator = NO;
        _msgTableView.showsVerticalScrollIndicator = NO;
        _msgTableView.estimatedRowHeight = 100;
        _msgTableView.rowHeight = UITableViewAutomaticDimension;
        [self addSubview:_msgTableView];
        [_msgTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.offset(0);
        }];
        _cellInfos = [NSMutableArray array];
    }
    return self;
}
-(void)addComment:(ETMSLiveComModel *)model{
    [_cellInfos addObject:model];
    [_msgTableView reloadData];
    [_msgTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_cellInfos.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}
#pragma mark - TableView 相关的代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _cellInfos.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ETMSLiveComModel *model = _cellInfos[indexPath.row];
    if(indexPath.row % 2 == 0){
        ETMSLiveCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        if(!cell){
            cell = [[ETMSLiveCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commentCell"];
        }
        [cell setCellInfo:model];
        return cell;
    }else{
        ETMSLiveCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCommentCell"];
        if(!cell){
            cell = [[ETMSLiveCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCommentCell"];
        }
        [cell setCellInfo:model];
        return cell;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    _msgTableView.backgroundColor = backgroundColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
