//
//  QZBRegisterAndLoginBaseVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBServerManager.h"
#import "QZBUser.h"

@interface QZBRegisterAndLoginBaseVC : UIViewController

- (BOOL)validateEmail:(NSString *)candidate;
- (BOOL)validatePassword:(NSString *)candidate;
- (BOOL)validateUsername:(NSString *)candidate;

- (void)shake:(UIView *)theOneYouWannaShake
    direction:(int)direction
       shakes:(int)shakes;
@end
