//
//  OrderVC.h
//  com.yizan.vso2o.business
//
//  Created by zzl on 15/4/13.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "BaseVC.h"

@interface OrderVC : BaseVC
///
@property (nonatomic,assign) int mtype;//0
///是否加载数据
@property (nonatomic,assign) BOOL isloaddata;

@property (nonatomic,strong) NSString *orderStr;

@end
