//
//  StatusView.m
//  BeeRanger
//
//  Created by sugc on 2019/4/7.
//  Copyright © 2019 sugc. All rights reserved.
//

#import "StatusView.h"
#import "UIView+FrameAccessor.h"
#import "UtilsDef.h"
#import "NewWorkManager/NewWorkManager.h"
#import "NewWorkManager/LocationManager.h"

@interface StatusView ()


@property (nonatomic, strong) UIButton *restButton;

@property (nonatomic, strong) UIButton *shrinkBtn;

@property (nonatomic, strong) UIButton *button1;

@property (nonatomic, strong) UIButton *button2;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImageView *leftImageView;

@property (nonatomic, strong) UIImageView *centerImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) TaskStatus status;

@end

@implementation StatusView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (CGRectContainsPoint(view.frame, point) && view.alpha > 0) {
            CGPoint newPoint = [self convertPoint:point toView:view];
            return [view hitTest:newPoint withEvent:event];
        }
    }
    return nil;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _status = -1;
        [self layout];
        [self changeToStatus:TaskStatusRequest msg:nil animate:NO];
    }
    
    return self;
}

- (void)layout {
    
    _restButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 200, 40, 40)];
    [_restButton setBackgroundImage:[UIImage imageNamed:@"btn_map_reset"] forState:UIControlStateNormal];
    [_restButton addTarget:self action:@selector(resetMap) forControlEvents:UIControlEventTouchUpInside];
    _restButton.layer.cornerRadius = 20;
    _restButton.layer.masksToBounds = YES;
    _restButton.bottom = ScreenHeight - 200;
    [self addSubview:_restButton];
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.frame = CGRectMake(10, self.height, self.width - 20, 40);
    [self addSubview:_contentView];
    
    _shrinkBtn = [[UIButton alloc] initWithFrame:CGRectMake(_contentView.width - 20 - 10, 10, 20, 10)];
    [_shrinkBtn setBackgroundImage:[UIImage imageNamed:@"up_down_arrow"] forState:UIControlStateNormal];
    
    [_contentView addSubview:_shrinkBtn];
    
    _imageView = [[UIImageView alloc] init];
    [_contentView addSubview:_imageView];
    
    _leftImageView = [[UIImageView alloc] init];
    [_contentView addSubview:_leftImageView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.numberOfLines = 0;
    [_contentView addSubview:_titleLabel];
    
//    _subTitleLabel = [[UILabel alloc] init];
//    _subTitleLabel.numberOfLines = 0;
//    [_contentView addSubview:_subTitleLabel];
    
    _button1 = [[UIButton alloc] init];
    _button1.layer.cornerRadius = 5;
    _button1.layer.masksToBounds = YES;
    _button1.titleLabel.textColor = [UIColor whiteColor];
    _button1.size = CGSizeMake(120, 44);
    [_button1 addTarget:self action:@selector(clickBtn1) forControlEvents:UIControlEventTouchUpInside];
    
    _button2 = [[UIButton alloc] init];
    _button2.layer.cornerRadius = 5;
    _button2.layer.masksToBounds = YES;
    _button2.titleLabel.textColor = [UIColor grayColor];
    _button2.size = CGSizeMake(120, 44);
    [_button2 addTarget:self action:@selector(clickBtn2) forControlEvents:UIControlEventTouchUpInside];
    
    [_contentView addSubview:_button1];
    [_contentView addSubview:_button2];
    
    _centerImageView = [[UIImageView alloc] init];
    [self addSubview:_centerImageView];
    _centerImageView.hidden = YES;
    _centerImageView.image = [UIImage imageNamed:@"status_none_centerImage"];
    CGFloat imgW = ScreenWidth / 3.0;
    CGFloat imgH = imgW / _centerImageView.image.size.width * _centerImageView.image.size.height;
    _centerImageView.size = CGSizeMake(imgW, imgH);
    _centerImageView.centerX = self.width / 2.0;
    _centerImageView.centerY = self.height / 2.0;
    _centerImageView.hidden = YES;
}

- (void)changeToStatus:(TaskStatus)staus msg:(NSDictionary *)msg animate:(BOOL)animate {
    
    if (staus <= self.status) {
        return;
    }
    self.status = staus;
    
    if (!animate) {
        [self refreshRiderWithStatus:staus msg:msg];
        _contentView.bottom = _contentView.bottom = self.height - 5 - 10;
        _restButton.alpha = 1.0;
        CGFloat space = 200 > (_contentView.height + 15) ? 200 : (_contentView.height + 15);
        _restButton.bottom = self.height - space - 15;
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.top = self.height;
        self.restButton.alpha = 0.0;
    }completion:^(BOOL finished) {
        [self refreshRiderWithStatus:staus msg:msg];
        CGFloat space = 200 > (self.contentView.height + 15) ? 200 : (self.contentView.height + 15);
        self.restButton.bottom = self.height - space - 15;
        [UIView animateWithDuration:0.3 animations:^{
            self.contentView.bottom = self.height - 5 - 10;
            self.restButton.alpha = 1.0;
        }];
    }];
    
}


//Rider状态刷新
- (void)refreshRiderWithStatus:(TaskStatus)status msg:(NSDictionary *)msg {
    _button1.hidden = YES;
    _button2.hidden = YES;
    _imageView.hidden = YES;
    _leftImageView.hidden = YES;
    
    if (status == TaskStatusNone || status == TaskStatusRequest) {
        //啥也不展示
        _contentView.top = self.height;
        return;
    }
    
    if (status == TaskStatusWaitingForReply) {
        //等待应答
        _imageView.image = [UIImage imageNamed:@"people"];
        _imageView.width = 18;
        _imageView.height = 38;
        _imageView.centerX = _contentView.width / 2.0;
        _imageView.top = 40;
        _imageView.hidden = NO;
        
        NSString *str = @"您附近有一个骑士需要救援！\n前去救援？";
        _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:str attributes:@{
                                                                                                         NSFontAttributeName :[UIFont systemFontOfSize:16]
                                                                                                         }];
        [_titleLabel sizeToFit];
        _titleLabel.top = _imageView.bottom + 15;
        _titleLabel.centerX = _contentView.width / 2.0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [_button1 setTitle:@"否" forState:UIControlStateNormal];
        [_button1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _button1.layer.borderColor = [UIColor grayColor].CGColor;
        _button1.layer.borderWidth = 1;
        
        _button1.top = _titleLabel.bottom + 20;
        _button2.top = _button1.top;

        [_button2 setTitle:@"是" forState:UIControlStateNormal];
        [_button2 setBackgroundImage:[UIImage imageNamed:@"button_search_for_help"] forState:UIControlStateNormal];
        _button1.hidden = NO;
        _button2.hidden = NO;
        
        _button1.centerX = _contentView.width * 0.25;
        _button2.centerX = _contentView.width * 0.75;
        
        _contentView.height = _button1.bottom + 20;
    }
    
    if (status == TaskStatusBegin) {
        //任务开始
        _shrinkBtn.hidden = YES;
        _imageView.image = [UIImage imageNamed:@"img_phone_call"];
        _imageView.width = 47;
        _imageView.height = 12;
        _imageView.right = _contentView.width - 20;
        _imageView.top = 15;
        

        
        _leftImageView.image = [UIImage imageNamed:@"left_arrow"];
        _leftImageView.width = 11;
        _leftImageView.height = 19;
        _leftImageView.left = 15;
        _leftImageView.hidden = NO;
        
        NSString *str = @"5分钟\n1.7km";
        _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:str attributes:@{
                                                                                                 NSFontAttributeName :[UIFont systemFontOfSize:16]
                                                                                                 }];
        [_titleLabel sizeToFit];
        _titleLabel.top = 20;
        _titleLabel.left = _leftImageView.right + 10;
        
        _leftImageView.centerY = _titleLabel.centerY;
        _imageView.hidden = NO;
        
        
        _contentView.height = _titleLabel.bottom + 20;
    }
    
    if (status == TaskStatusArrived) {
        //抵达终点
        
        
        
        _leftImageView.image = [UIImage imageNamed:@"people"];
        _leftImageView.width = 18;
        _leftImageView.height = 38;
        _leftImageView.left = 20;
        _leftImageView.top = 40;
        _leftImageView.hidden = NO;
        
        
        _imageView.image = [UIImage imageNamed:@"img_phone_call"];
        _imageView.width = 47;
        _imageView.height = 12;
        _imageView.centerY = _leftImageView.centerY;
        _imageView.right = _contentView.width - 20;
     
        _imageView.hidden = NO;

        
        NSString *str = @"您已到达救援地点";
        _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:str attributes:@{
                                                                                                 NSFontAttributeName :[UIFont systemFontOfSize:16]
                                                                                                 }];
        [_titleLabel sizeToFit];
        _titleLabel.top = _leftImageView.bottom + 10;
        _titleLabel.centerX = _contentView.width / 2.0;
        
        [_button2 setBackgroundImage:[UIImage imageNamed:@"button_in_help"] forState:UIControlStateNormal];
        [_button2 setTitle:@"下一步" forState:UIControlStateNormal];
        _button2.centerX = _contentView.width / 2.0;
        _button2.top = _titleLabel.bottom + 20;
        _button2.hidden = NO;
        
        _contentView.height = _button2.bottom + 20;
    }
    
    if (status == TaskStatusComplete) {
        //完成交换
        
        _leftImageView.image = [UIImage imageNamed:@"people"];
        _leftImageView.width = 18;
        _leftImageView.height = 38;
        _leftImageView.left = 20;
        _leftImageView.top = 40;
        _leftImageView.hidden = NO;
        
        
        _imageView.image = [UIImage imageNamed:@"img_phone_call"];
        _imageView.width = 47;
        _imageView.height = 12;
        _imageView.centerY = _leftImageView.centerY;
        _imageView.right = _contentView.width - 20;
        
        _imageView.hidden = NO;
        
        
        NSString *str = @"是否完成交换？";
        _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:str attributes:@{
                                                                                                 NSFontAttributeName :[UIFont systemFontOfSize:16]
                                                                                                 }];
        [_titleLabel sizeToFit];
        _titleLabel.top = _leftImageView.bottom + 10;
        _titleLabel.centerX = _contentView.width / 2.0;
        
        
        [_button1 setTitle:@"否" forState:UIControlStateNormal];
        [_button1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _button1.layer.borderColor = [UIColor grayColor].CGColor;
        _button1.layer.borderWidth = 1;
        
        _button1.top = _titleLabel.bottom + 20;
        _button2.top = _button1.top;
        
        [_button2 setTitle:@"是" forState:UIControlStateNormal];
        [_button2 setBackgroundImage:[UIImage imageNamed:@"button_in_help"] forState:UIControlStateNormal];
        _button1.hidden = NO;
        _button2.hidden = NO;
        
        _button1.centerX = _contentView.width * 0.25;
        _button2.centerX = _contentView.width * 0.75;
        
        _contentView.height = _button2.bottom + 20;
        
       
        
    }
    
}


- (void)resetMap {
     [[LocationManager shareInstance] resetMapViewToCenter];
}

//z重置t地图到中心
- (void)clickBtn1 {
   
}

//
- (void)clickBtn2 {
    if ((_status + 1) == TaskStatusNone) {
        //显示分享页面
        return;
    }
    [[NewWorkManager shareInstance] updateHelpMsgWithStatus:self.status + 1];
}

- (void)showShareView {
    //展示分享页面
    
}

@end
