//
//  HelpViewController.h
//  Norwich
//
//  Created by  James on 23/03/2019.
//  Copyright © 2019 CoDeveloper. All rights reserved.
//

#import "BaseViewController.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HelpViewController : BaseViewController <WKNavigationDelegate>
{
    NSString *urlString;
}

    @property (nonatomic, retain) IBOutlet WKWebView *webView;
    @property (nonatomic, retain) IBOutlet UIButton *backButton;
    @property (nonatomic, retain) IBOutlet UIButton *startButton;
    @property (nonatomic, retain)  NSString *url;

    -(IBAction)backPage:(id) sender;

@end

NS_ASSUME_NONNULL_END
