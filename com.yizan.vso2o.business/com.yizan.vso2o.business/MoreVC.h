//
//  MoreVC.h
//  com.yizan.vso2o.business
//
//  Created by zzl on 15/4/13.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "BaseVC.h"

@interface MoreVC : BaseVC
///头像图片
@property (weak, nonatomic) IBOutlet UIImageView *headerImg;
///姓名
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
///电话号码
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLb;
///切换按钮
@property (weak, nonatomic) IBOutlet UIButton *changgeBtn;
///信息
@property (weak, nonatomic) IBOutlet UIButton *msgBtn;
///关于我们
@property (weak, nonatomic) IBOutlet UIButton *aboutUsBTn;
///检查更新
@property (weak, nonatomic) IBOutlet UIButton *updataBtn;
///信息提示hud圆点
@property (weak, nonatomic) IBOutlet UIImageView *firstPionImg;
///检查更新hud圆点
@property (weak, nonatomic) IBOutlet UIImageView *secondPiontImg;

@property (weak, nonatomic) IBOutlet UIView *topBgkVC;
///意见反馈按钮
@property (weak, nonatomic) IBOutlet UIButton *feedBackBtn;

@end
