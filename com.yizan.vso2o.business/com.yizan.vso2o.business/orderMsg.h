//
//  orderMsg.h
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface orderMsg : UIView
///服务项目图片
@property (weak, nonatomic) IBOutlet UIImageView *productImg;
///服务项目名称
@property (weak, nonatomic) IBOutlet UILabel *serviceNameLb;
///价格
@property (weak, nonatomic) IBOutlet UILabel *priceLb;
///服务时间
@property (weak, nonatomic) IBOutlet UILabel *serviceTimeLb;

+ (orderMsg *)shareView;
@end
