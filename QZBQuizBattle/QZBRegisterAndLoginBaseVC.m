//
//  QZBRegisterAndLoginBaseVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRegisterAndLoginBaseVC.h"

@interface QZBRegisterAndLoginBaseVC ()

@end

@implementation QZBRegisterAndLoginBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - validation

- (BOOL)validateEmail:(NSString *)candidate {
  NSString *emailRegex =
  @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";  //([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})
  NSPredicate *emailTest =
  [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
  
  return [emailTest evaluateWithObject:candidate];
}

- (BOOL)validatePassword:(NSString *)candidate {
  return ([candidate length] >= 6);
}

- (BOOL)validateUsername:(NSString *)candidate {
  return ([candidate length] <= 20 && [candidate length] >= 2);
}

#pragma mark - shake

- (void)shake:(UIView *)theOneYouWannaShake
    direction:(int)direction
       shakes:(int)shakes {
  
  
  [UIView animateWithDuration:0.03
                   animations:^{
                     theOneYouWannaShake.transform =
                     CGAffineTransformMakeTranslation(5 * direction, 0);
                   }
                   completion:^(BOOL finished) {
                     if (shakes >= 10) {
                       theOneYouWannaShake.transform = CGAffineTransformIdentity;
                       return;
                     }
                     __block int shakess = shakes;
                     shakess++;
                     __block int directionn = direction;
                     directionn = directionn*-1;
                     [self shake:theOneYouWannaShake direction:directionn shakes:shakess];
                   }];
}




@end
