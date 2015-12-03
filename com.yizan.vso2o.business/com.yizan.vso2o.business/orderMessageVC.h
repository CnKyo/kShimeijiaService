//
//  orderMessageVC.h
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "BaseVC.h"


@interface orderMessageVC : BaseVC

@property (nonatomic,strong) NSString *msgStr;

@property (nonatomic,strong) UIButton *servceBtn;


@property (nonatomic,strong)    SOrder  * mtagorder;

@property (nonatomic,assign) BOOL mbedit;

@property (nonatomic,assign) BOOL   mSref;
///订单id
//@property (nonatomic,assign) int orderId;//0
///从信息界面返回的判断值
@property (nonatomic,assign) int who;//0


@end
