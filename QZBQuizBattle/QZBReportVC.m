//
//  QZBReportVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBReportVC.h"
#import "UIButton+QZBButtonCategory.h"
#import "QZBServerManager.h"
#import <TSMessages/TSMessage.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface QZBReportVC () <UITextViewDelegate>

@property (strong, nonatomic) id<QZBUserProtocol> user;

@end

@implementation QZBReportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reportTextView.delegate = self;

    [self registerForKeyboardNotifications];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.reportButton configButtonWithRoundedBorders];
    self.reportButton.enabled = YES;

    [self.reportButton setTitle:@"Отправить жалобу" forState:UIControlStateNormal];
    self.reportTextView.text = @"";

    [self.reportTextView becomeFirstResponder];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initWithUser:(id<QZBUserProtocol>)user {
    self.user = user;
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.buttonBottomSpaceConstraint.constant = kbSize.height;
                         [self.reportButton layoutIfNeeded];
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.buttonBottomSpaceConstraint.constant = 0;
                         [self.view layoutIfNeeded];
                     }];
}

- (IBAction)sendReportAction:(id)sender {
    //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    if (self.reportTextView.text.length > 0) {
        if(self.user) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [[QZBServerManager sharedManager] GETReportForUserID:self.user.userID
            message:self.reportTextView.text
            onSuccess:^{

                [self afterSend];
            }
            onFailure:^(NSError *error, NSInteger statusCode) {
                [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];

            }];
        } else {
            NSLog(@"no user ");
            [[QZBServerManager sharedManager]
             POSTReportForDevelopersWithMessage:self.reportTextView.text onSuccess:^{
                [self afterSend];
                
            
            } onFailure:^(NSError *error, NSInteger statusCode) {
                   [SVProgressHUD showErrorWithStatus:QZBNoInternetConnectionMessage];
            }];
        }
    } else {
        [SVProgressHUD showErrorWithStatus:@"Пустая жалоба"];
    }
}

-(void)afterSend {
    [SVProgressHUD showSuccessWithStatus:@"Жалоба отправлена " @"успеш"
     @"но"];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                       
                       [self.navigationController popViewControllerAnimated:YES];
                   });
    


}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        //  [textView resignFirstResponder];

        [self sendReportAction:nil];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;

    //    NSArray* components = [textView.text componentsSeparatedByString:@"\n"];
    //    if ([components count] > 0) {
    //       // NSString* commandText = [components lastObject];
    //        // and optionally clear the text view and hide the keyboard...
    //        textView.text = @"";
    //        [textView resignFirstResponder];
    //        return NO;
    //    }

    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
