//
//  UIViewController+QZBMessagerCategory.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (QZBMessagerCategory)

-(void)subscribeToMessages;
-(void)unsubscribeFromMessages;

@end
