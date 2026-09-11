//
//  HelpViewController.m
//  Norwich
//
//  Created by  James on 23/03/2019.
//  Copyright © 2019 CoDeveloper. All rights reserved.
//

#import "HelpViewController.h"
#import "TrailList.h"
#import "SendServerData.h"
#import "Reachability.h"
#import "PHLogger.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

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
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                  NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                  if (networkStatus == NotReachable)
                  {
                      
                      [PHLogger showMessage:@"Internet Connection seems to be off. Please connect to internet to see this screen" withViewContoller:self];
                      
                      return;
                      
                  }
    
}
-(void) setup
{
    
    urlString = [NSString stringWithFormat:@"%@/%@",[SendServerData getServerName],self.url];

    NSURL *url = [NSURL URLWithString:urlString];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    _webView.navigationDelegate = self;
    [self.backButton setHidden:YES];
    
    
}

-(UIScrollView *)viewForZoomingInScrollView
{
    return _webView.scrollView;
}

-(IBAction)backPage:(id) sender
{
    [self.webView goBack];
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    
    // forecast there because it gets loaded twice in safety
    if ([[navigationAction.request.URL absoluteString ] rangeOfString:urlString ].location > 0)
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
