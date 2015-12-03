//
//  cmmtopview.h
//  com.yizan.vso2o.business
//
//  Created by zzl on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class myProcessView;

@interface cmmtopview : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *mhead;
@property (weak, nonatomic) IBOutlet UILabel *mname;
@property (weak, nonatomic) IBOutlet UILabel *mgoodtxt;
@property (weak, nonatomic) IBOutlet UILabel *mmidtxt;
@property (weak, nonatomic) IBOutlet UILabel *mlowtxt;

@property (weak, nonatomic) IBOutlet myProcessView *mgoodpr;
@property (weak, nonatomic) IBOutlet myProcessView *mmidpr;
@property (weak, nonatomic) IBOutlet myProcessView *mlowpr;

-(void)updatePageInfo;


@end
