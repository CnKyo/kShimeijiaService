//
//  historyOrderVC.h
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "BaseVC.h"

@interface historyOrderVC : BaseVC
@property (nonatomic,assign) int mtype;//0
@property (nonatomic,strong)    UIViewController *historyVC;

@property (nonatomic,strong) NSString *historyStr;

///是否加载数据
@property (nonatomic,assign) BOOL isloaddata;


@end
