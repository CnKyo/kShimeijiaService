//
//  botomview.m
//  com.yizan.vso2o.business
//
//  Created by zzl on 15/4/16.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "botomview.h"

@interface botomview ()

@end

@implementation botomview

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

 
- (IBAction)ttt:(id)sender {
    if( _msel && _mtag )
        [_mtag performSelector:_msel withObject:sender];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
