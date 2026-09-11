//
//  MenuViewController.h
//  RevealControllerStoryboardExample
//
//  Created by Nick Hodapp on 1/9/13.
//  Copyright (c) 2013 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface MoreViewController : BaseViewController
{
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *sendingView;

-(void)start;


@end
