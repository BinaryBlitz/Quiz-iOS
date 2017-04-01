#import "QZBAboutTVC.h"
#import <MessageUI/MessageUI.h>

@interface QZBAboutTVC () <MFMailComposeViewControllerDelegate>

@end

@implementation QZBAboutTVC

#pragma mark - Table view data source

- (IBAction)sendEmail:(UIButton *)sender {

  NSString *emailTitle = @"Ваш вопрос или предложение";

  NSArray *toRecipents = [NSArray arrayWithObject:@"1na1@binaryblitz.ru"];

  MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
  mc.mailComposeDelegate = self;
  [mc setSubject:emailTitle];
  [mc setToRecipients:toRecipents];

  [self presentViewController:mc animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
  switch (result) {
    case MFMailComposeResultCancelled:
      NSLog(@"Mail cancelled");
      break;
    case MFMailComposeResultSaved:
      NSLog(@"Mail saved");
      break;
    case MFMailComposeResultSent:
      NSLog(@"Mail sent");
      break;
    case MFMailComposeResultFailed:
      NSLog(@"Mail sent failure: %@", [error localizedDescription]);
      break;
    default:
      break;
  }

  // Close the Mail Interface
  [self dismissViewControllerAnimated:YES completion:NULL];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}


@end
