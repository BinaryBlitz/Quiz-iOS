#import "QZBRegisterAndLoginBaseVC.h"
#import "TSMessage.h"

@interface QZBRegisterAndLoginBaseVC ()

@end

@implementation QZBRegisterAndLoginBaseVC

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [TSMessage setDefaultViewController:self];
  [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [TSMessage dismissActiveNotification];
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
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
}

#pragma mark - validation

#pragma mark - shake

- (void)shake:(UIView *)theOneYouWannaShake direction:(int)direction shakes:(int)shakes {
  [UIView animateWithDuration:0.03
                   animations:^{
                     theOneYouWannaShake.transform = CGAffineTransformMakeTranslation(5 * direction, 0);
                   }
                   completion:^(BOOL finished) {
                     if (shakes >= 10) {
                       theOneYouWannaShake.transform = CGAffineTransformIdentity;
                       return;
                     }
                     __block int shakess = shakes;
                     shakess++;
                     __block int directionn = direction;
                     directionn = directionn * -1;
                     [self shake:theOneYouWannaShake direction:directionn shakes:shakess];
                   }];
}

#pragma mark - errors

- (IBAction)dismisVC:(id)sender {
  [self dismissViewControllerAnimated:YES
                           completion:^{
                           }];
}

@end
