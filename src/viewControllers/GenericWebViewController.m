//
//  GenericWebViewController.m
//  YorkshireDales
//
//  Created by  James on 24/02/2015.
//  Copyright (c) 2015 CoDeveloper. All rights reserved.
//

#import "GenericWebViewController.h"
#import "AppConfiguration.h"
#import "TrailList.h"

@interface GenericWebViewController ()

@end

@implementation GenericWebViewController
@synthesize fileName,backButton,webView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup ];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([TrailList onTrail])
    {
        [self.startButton setHidden:YES];
    }
   
    _titleLabel.text  = [fileName capitalizedStringWithLocale:[NSLocale currentLocale]];

}
-(void) setup
{
    if (fileName == nil)
    {
        fileName = @"intro";
        _titleLabel.text = @"Introduction";

    }
    
    NSString *fullfileName = [fileName stringByAppendingString:@".html"];
    
    fullfileName = [NSString stringWithFormat:@"%@/%@",[AppConfiguration getContentFolder] ,fullfileName];

    NSURL *url = [NSURL URLWithString:fullfileName];
    
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    
    
    [self setTitle:[fileName capitalizedString]];
    
    webView.navigationDelegate = self;
    [self.backButton setHidden:YES];


}

-(UIScrollView *)viewForZoomingInScrollView
{
    return webView.scrollView;
}

-(IBAction)backPage:(id) sender
{
    [self.webView goBack];
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString *searchString =[fileName stringByAppendingString:@".htm" ];

    // forecast there because it gets loaded twice in safety
    if ([[navigationAction.request.URL absoluteString ] rangeOfString:@"britishnewspaperarchive" ].location != NSNotFound)
    {
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:navigationAction.request.URL options:@{} completionHandler:nil];
        
        decisionHandler(WKNavigationActionPolicyCancel);

    }
        
        else if ([[navigationAction.request.URL absoluteString ] rangeOfString:searchString ].location  != NSNotFound)
        {
            [self.backButton setHidden:YES];
        }
    else{
        [self.backButton setHidden:NO];

    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}
-(IBAction) back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
