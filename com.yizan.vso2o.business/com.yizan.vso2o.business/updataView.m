//
//  updataView.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/17.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "updataView.h"

@implementation updataView

+ (updataView *)share{
    updataView *view = [[[NSBundle mainBundle]loadNibNamed:@"updataView" owner:self options:nil]objectAtIndex:0];
    return view;
}

@end
