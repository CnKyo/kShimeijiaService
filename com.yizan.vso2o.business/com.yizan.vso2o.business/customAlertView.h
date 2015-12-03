//
//  customAlertView.h
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/16.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customAlertView : UIView
///背景
@property (weak, nonatomic) IBOutlet UIView *bgView;
///背景
@property (weak, nonatomic) IBOutlet UIView *bgkVC;
///图片
@property (weak, nonatomic) IBOutlet UIImageView *img;
///内容
@property (weak, nonatomic) IBOutlet UILabel *contentLb;
///按钮
@property (weak, nonatomic) IBOutlet UIButton *btn;

+ (customAlertView *)shareView;
@end
