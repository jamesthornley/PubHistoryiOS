//
//  TapGestureWithNote.h
//  HistoricPubCrawl
//
//  Created by  James on 03/03/2019.
//  Copyright © 2019 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

@interface TapGestureWithNote : UITapGestureRecognizer

@property  Note *note;

@end

NS_ASSUME_NONNULL_END
