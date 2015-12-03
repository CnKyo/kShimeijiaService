//
//  NavBar.m
//  gameInfo
//
//  Created by lijiangang on 14-1-22.
//  Copyright (c) 2014年 lijiangang. All rights reserved.
//

#import "NavBar.h"
#import "CustomDefine.h"
@implementation NavBar
{
    UIImageView *bgimageview;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = COLOR(231, 105, 105);
       // self.backgroundColor = [UIColor redColor];

        // Initialization code

        self.frame = CGRectMake(0, 0, 320, DEVICE_NavBar_Height);
        bgimageview = [[UIImageView alloc]initWithFrame:self.frame];
        [self addSubview:bgimageview];
        [self loadView];
    }
    return self;
}
- (void)leftBtnTouched:(id)sender {
    [self.NavDelegate leftBtnTouched:sender];

}
-(void)setBgImage:(UIImage *)bgImage
{
    bgimageview.image = bgImage;
}
-(void)setBgColor:(UIColor *)bgColor
{
    bgimageview.backgroundColor = bgColor;
}
-(void)rightbtnTouched:(id)sender
{	
    [self.NavDelegate rightBtnTouched:sender];
}


-(void)loadView
{
    self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (SystemIsiOS7()) {
        self.leftBtn.frame = CGRectMake(0, 20,100, 44);
        self.leftBtn.imageEdgeInsets  = UIEdgeInsetsMake(0, 0, 0, 20);
        self.leftBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
        self.rightBtn.frame = CGRectMake(260, 20, 60, 44);
        self.rightBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
        self.titleLabel  = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
        self.titleLabel.center = self.center;
        CGRect rect = self.titleLabel.frame;
        rect.origin.y+=10;
        self.titleLabel.frame = rect;
    }
    else
    {
        self.leftBtn.frame = CGRectMake(0, 0,50, 60);
        self.rightBtn.frame = CGRectMake(230, 20, 123, 31);

        self.titleLabel  = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
        
        self.titleLabel.center = self.center;
     //   CGRect rect = self.titleLabel.frame;
      //  rect.origin.y＋;
    }
    
      //  self.backBtn.backgroundColor = [UIColor redColor];
   // [self.backBtn setTitle:@"<" forState:UIControlStateNormal];
  //  [self.leftBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.leftBtn setImage:[UIImage imageNamed:@"backBtna.png"] forState:UIControlStateNormal];
    self.leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 50);
    [self addSubview:self.leftBtn];
    
    [self.rightBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self addSubview:self.rightBtn];
        [self.rightBtn addTarget:self action:@selector(rightbtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftBtn addTarget:self action:@selector(leftBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
   // self.title.text = self.title;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = COLOR(255, 255, 255);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self addSubview:self.titleLabel];
   }
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
