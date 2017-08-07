//
//  ETMSLiveCommentTableViewCell.m
//  MastеrsSеriеs
//
//  Created by pptk on 2017/7/24.
//  Copyright © 2017年 8wm. All rights reserved.
//

#import "ETMSLiveCommentTableViewCell.h"
#import <Masonry/Masonry.h>

@interface ETMSLiveCommentTableViewCell()
{
    QMUIButton *headerBtn;
    QMUILabel *nameLabel;
    QMUILabel *commentLabel;
    
    UIView *commentBgView;
}
@end

@implementation ETMSLiveCommentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // init 时做的事情请写在这里
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
        
        if([reuseIdentifier isEqualToString:@"myCommentCell"]){
            [self setRight];
        }else{
            [self setLeft];
        }
    }
    return self;
}

- (void)updateCellAppearanceWithIndexPath:(NSIndexPath *)indexPath {
    [super updateCellAppearanceWithIndexPath:indexPath];
    // 每次 cellForRow 时都要做的事情请写在这里
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)initSubViews{
    [self.contentView setBackgroundColor:HexRGB(0xf0f0f0)];
    headerBtn = ({
        QMUIButton *btn = [[QMUIButton alloc]init];
        [self.contentView addSubview:btn];
        btn;
    });
    nameLabel = ({
        QMUILabel *label = [[QMUILabel alloc]init];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = UIFontMake(10);
        [self.contentView addSubview:label];
        label;
    });
    commentBgView = ({
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = UIColorWhite;
        view.layer.borderWidth = 1*kScale;
        view.layer.borderColor = HexRGB(0xcdcdcd).CGColor;
        view.layer.cornerRadius = 6;
        view.layer.masksToBounds = YES;
        [self.contentView addSubview:view];
        view;
    });
    commentLabel = ({
        QMUILabel *label = [[QMUILabel alloc]init];
        label.numberOfLines = 0;
        label.font = UIFontMake(14);
        label.canPerformCopyAction = YES;
        
        [commentBgView addSubview:label];
        label;
    });
}
-(void)setLeft{
    [headerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(20*kScale));
        make.top.mas_equalTo(@(10*kScale));
        make.height.mas_equalTo(80*kScale);
        make.width.mas_equalTo(80*kScale);
        make.bottom.lessThanOrEqualTo(self.contentView.mas_bottom).offset(10*kScale);
    }];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerBtn.mas_right).with.offset(15*kScale);
        make.top.mas_equalTo(@(10*kScale));
    }];
    [commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(commentBgView.mas_left).with.offset(20*kScale);
        make.top.equalTo(commentBgView.mas_top).with.offset(20*kScale);
        make.right.equalTo(commentBgView.mas_right).with.offset(-20*kScale);
        make.bottom.equalTo(commentBgView.mas_bottom).with.offset(-20*kScale);
    }];
    [commentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameLabel.mas_left).with.offset(0);
        make.top.equalTo(nameLabel.mas_bottom).with.offset(10*kScale);
        make.right.lessThanOrEqualTo(self.contentView.mas_right).with.offset(-115*kScale);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-10*kScale);
    }];
}
- (void)setRight{
    commentBgView.backgroundColor = HexRGB(0x98dff8);
    commentBgView.layer.borderColor = HexRGB(0x45add1).CGColor;
    [headerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(@(-20*kScale));
        make.top.mas_equalTo(@(10*kScale));
        make.height.mas_equalTo(80*kScale);
        make.width.mas_equalTo(80*kScale);
    }];
    [commentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerBtn.mas_left).with.offset(-15*kScale);
        make.top.equalTo(headerBtn.mas_top).with.offset(0);
        make.left.greaterThanOrEqualTo(self.contentView.mas_left).with.offset(115*kScale);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-10*kScale);
    }];
    [commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(commentBgView.mas_left).with.offset(20*kScale);
        make.top.equalTo(commentBgView.mas_top).with.offset(20*kScale);
        make.right.equalTo(commentBgView.mas_right).with.offset(-20*kScale);
        make.bottom.equalTo(commentBgView.mas_bottom).with.offset(-20*kScale);
    }];
}

- (void)setCellInfo:(ETMSLiveComModel *)info{
    [headerBtn setBackgroundImage:UIImageMake(info.head) forState:UIControlStateNormal];
    nameLabel.text = info.name;
    commentLabel.attributedText = [self getAttr:info.comment];
    [commentLabel sizeToFit];
}

- (NSMutableAttributedString*)getAttr:(NSString*)str {
    NSMutableParagraphStyle   *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5.5];//行间距
    paragraphStyle.alignment = NSTextAlignmentJustified;//文本对齐方式 左右对齐（两边对齐）
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];//设置段落样式
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(0, [str length])];//设置字体大小
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [str length])];//这段话必须要添加，否则UIlabel两边对齐无效 NSUnderlineStyleAttributeName （设置下划线）
    return attributedString;
}

@end
