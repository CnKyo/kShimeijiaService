//
//  ContentScrollView.m
//  YiZanService
//
//  Created by ljg on 15-3-23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "ContentScrollView.h"

@implementation ContentScrollView
{
    CGFloat _maxOffset;
}
-(void)addSubview:(UIView *)view
{
    [super addSubview:view];
    if (self.needFix) {
        
        CGFloat  t = view.frame.origin.y+view.frame.size.height;
        if( t > _maxOffset )
        {
            _maxOffset = t;
            self.contentSize = CGSizeMake(self.bounds.size.width,_maxOffset);
        }
    }
}
-(void)willRemoveSubview:(UIView *)subview
{
    [super willRemoveSubview:subview];
    if ( NO ) {
        
        CGFloat  t = subview.frame.size.height + subview.frame.origin.y;
        if( t >= _maxOffset )
        {
            _maxOffset -= subview.frame.size.height;
//            MLLog(@"subview高度等于的时候：%f",subview.frame.size.height);
            self.contentSize = CGSizeMake(self.contentSize.width ,_maxOffset);
        }
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
