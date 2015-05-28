//
//  QZBMessagerVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 30/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "QZBUserProtocol.h"
#import <XMPPFramework.h>

@interface QZBMessagerVC : JSQMessagesViewController <XMPPStreamDelegate>

-(void)initWithUser:(id<QZBUserProtocol>)user;

//-(void)initWithUser:(id<QZBUserProtocol>)user userpic:(UIImage *)image;

@end
