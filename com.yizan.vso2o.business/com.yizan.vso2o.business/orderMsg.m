//
//  orderMsg.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "orderMsg.h"

@implementation orderMsg

+ (orderMsg *)shareView{

    orderMsg *view = [[[NSBundle mainBundle]loadNibNamed:@"View" owner:self options:nil]objectAtIndex:0];
    return view;
}

@end
