//
//  verifyOrder.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "verifyOrder.h"

@implementation verifyOrder

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(verifyOrder *)share{

    verifyOrder *view = [[[NSBundle mainBundle]loadNibNamed:@"verifyOrder" owner:self options:nil]objectAtIndex:0];
    return view;
}
@end
