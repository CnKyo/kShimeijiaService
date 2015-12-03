//
//  fuwuNeirong.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "fuwuNeirong.h"

@implementation fuwuNeirong

+ (fuwuNeirong *)shareView{
    fuwuNeirong *view = [[[NSBundle mainBundle]loadNibNamed:@"fuwuNeirong" owner:self options:nil]objectAtIndex:0];
    return view;
}

@end
