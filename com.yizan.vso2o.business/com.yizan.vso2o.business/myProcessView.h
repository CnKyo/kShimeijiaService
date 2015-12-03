//
//  myProcessView.h
//  com.yizan.vso2o.business
//
//  Created by zzl on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myProcessView : UIView

@property (nonatomic,strong)    UIColor*    mempcl;//空白颜色
@property (nonatomic,strong)    UIColor*    mfulcl;//填充颜色
@property (nonatomic,strong)    UIColor*    mborcl;//边框颜色


//max 1.0
-(void)setProcessValue:(float)v an:(BOOL)an;


@end
