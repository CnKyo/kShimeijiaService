//
//  verifyOrder.h
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CunsomLabel.h"
@interface verifyOrder : UIView
///服务数量
@property (weak, nonatomic) IBOutlet UILabel *serviceNumLb;
///服务时间
@property (weak, nonatomic) IBOutlet UILabel *serviceTimeLb;
///联系人姓名
@property (weak, nonatomic) IBOutlet UILabel *userNmaeLb;
///联系电话号码
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLb;
///服务地址
@property (weak, nonatomic) IBOutlet CunsomLabel *addressLb;
///订单编号
@property (weak, nonatomic) IBOutlet UILabel *orderNumCodeLb;
///备注
@property (weak, nonatomic) IBOutlet UILabel *noteLb;
///费用
@property (weak, nonatomic) IBOutlet UILabel *pricrLb;
///支付状态
@property (weak, nonatomic) IBOutlet UILabel *zhifuStatusLb;
///拨打按钮
@property (weak, nonatomic) IBOutlet UIButton *telphoneBtn;
///地图导航按钮
@property (weak, nonatomic) IBOutlet UIButton *mapNavigationBtn;
///顶部线条
@property (weak, nonatomic) IBOutlet UIView *topLineView;
///中部线条
@property (weak, nonatomic) IBOutlet UIView *midLineView;
///地步线条
@property (weak, nonatomic) IBOutlet UIView *footLineView;

@property (weak, nonatomic) IBOutlet UIImageView *topImgView;

+(verifyOrder *)share;
@end
