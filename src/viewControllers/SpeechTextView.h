//
//  SpeechTextView.h
//  HistoricPubCrawl
//
//  Created by  James on 02/08/2017.
//  Copyright © 2017 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface SpeechTextView : UILabel
{
    long cornerRadius;
}
@property (nonatomic) IBOutlet Note *note;

@end
