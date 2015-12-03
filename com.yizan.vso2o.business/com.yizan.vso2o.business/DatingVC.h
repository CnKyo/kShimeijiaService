//
//  DatingVC.h
//  com.yizan.vso2o.business
//
//  Created by zzl on 15/4/13.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "BaseVC.h"

@interface DatingVC : BaseVC


@property (nonatomic,assign) BOOL mbedit;

@property (nonatomic,assign) BOOL   mSref;


@property (nonatomic,weak) DatingVC*   mprevc;

@end
