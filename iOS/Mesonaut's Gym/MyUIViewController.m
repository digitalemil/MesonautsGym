//
//  MyUIViewController.m
//  Horton's Gym
//
//  Created by Emil on 11/05/15.
//  Copyright (c) 2015 digitalemil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MyUIViewController.h"

extern NSString *userstr, *serverstr;
extern NSString *server1,*server2, *servertotry, *servertried;

@interface MyUIViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation MyUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ui/hr.html" ofType:nil];
     self.webview.delegate = self;
    [self.webview  loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *f= [NSString stringWithFormat:@"myStartFunction('%@','%@','%@')", server1, server2, userstr ];
    [self.webview stringByEvaluatingJavaScriptFromString:f];
}
@end
