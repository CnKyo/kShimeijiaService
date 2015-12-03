//
//  myProcessView.m
//  com.yizan.vso2o.business
//
//  Created by zzl on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "myProcessView.h"

@implementation myProcessView
{
    UIView* _vv;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        if( !_mempcl )//空白颜色
        {
            self.mempcl = [UIColor whiteColor];
        }
        if( !_mfulcl )//填充
        {
            self.mfulcl = M_CO;
        }
        if( !_mborcl )//边框颜色
        {
            self.mborcl = [UIColor colorWithWhite:0.812 alpha:1.000];
        }
        _vv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, self.bounds.size.height)];
        [self addSubview:_vv];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if( self )
    {
        if( !_mempcl )//空白颜色
        {
            self.mempcl = [UIColor whiteColor];
        }
        if( !_mfulcl )//填充颜色
        {
            self.mfulcl = M_CO;
        }
        if( !_mborcl )//边框颜色
        {
            self.mborcl = [UIColor colorWithWhite:0.812 alpha:1.000];
        }
        _vv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, self.bounds.size.height)];
        [self addSubview:_vv];
        
    }
    
    return self;
}
-(void)setProcessValue:(float)v an:(BOOL)an
{
    self.layer.borderColor = [_mborcl CGColor];
    self.layer.borderWidth = 0.5f;
    self.layer.cornerRadius = 0.3f;
    
    self.backgroundColor = _mempcl;
    _vv.backgroundColor = _mfulcl;
    
    if( an )
    {
        [UIView animateWithDuration:1 animations:^{
            
            CGRect f = _vv.frame;
            f.size.width = v * self.bounds.size.width;
            _vv.frame = f;
            
        }];
    }
    else
    {
        CGRect f = _vv.frame;
        f.size.width = v * self.bounds.size.width;
        _vv.frame = f;
    }
    
    
    
    
    
    
}
/*
 
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
