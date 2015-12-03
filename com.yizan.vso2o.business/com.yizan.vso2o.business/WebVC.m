//
//  WebVC.m
//  YiZanService
//
//  Created by zzl on 15/3/29.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "WebVC.h"

@interface WebVC ()<UIWebViewDelegate>

@end

@implementation WebVC

-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
}
- (void)viewDidLoad {
    self.mPageName = @"WEB浏览";
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.Title = self.mName;
    UIWebView* itwebview = [[UIWebView alloc]initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:itwebview];
    itwebview.delegate = self;
    [SVProgressHUD showWithStatus:@"加载中..."];
    [itwebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.mUrl]]];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD showWithStatus:@"加载中..."];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:error.description];
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
