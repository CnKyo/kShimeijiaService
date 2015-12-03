//
//  customAlertView.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/16.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "customAlertView.h"

@implementation customAlertView

+(customAlertView *)shareView{
    customAlertView *view = [[[NSBundle mainBundle]loadNibNamed:@"customAlerView" owner:self options:nil]objectAtIndex:0];
    return view;

}

@end
