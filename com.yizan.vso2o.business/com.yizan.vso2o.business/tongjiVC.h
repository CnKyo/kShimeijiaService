//
//  tongjiVC.h
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/16.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "BaseVC.h"

@interface tongjiVC : BaseVC


//获取统计数据,month = -1 表示 按照月份来统计,0 表示最近统计数据,
@property (nonatomic,assign) int month;

@property (nonatomic,assign) int myeaer;

@property (nonatomic,assign) BOOL mbedit;

@property (nonatomic,assign) BOOL   mSref;


///订单id
@property (nonatomic,assign) int orderId;//0

@end
