//
//  QZBReportVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@interface QZBReportVC : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UITextView *reportTextView;

-(void)initWithUser:(id<QZBUserProtocol>)user;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonBottomSpaceConstraint;

@end
