//
//  QZBRegistrationChooserVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VKSdk.h>
@interface QZBRegistrationChooserVC : UIViewController <VKSdkDelegate>
@property (weak, nonatomic) IBOutlet UIButton *vkButton;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UIButton *registrationButton;

@end
