//
//  ListTrailsViewController.h
//  London
//
//  Created by  James on 21/03/2021.
//  Copyright © 2021 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "PHAleTrail.h"

NS_ASSUME_NONNULL_BEGIN

@interface ListTrailsViewController : BaseViewController  <UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *pHAleTrailArray;
    
    PHAleTrail * selectedTrail;
}
@end

NS_ASSUME_NONNULL_END
