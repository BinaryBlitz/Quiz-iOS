#import <UIKit/UIKit.h>
#import <VKSdk.h>

@interface QZBRegistrationChooserVC : UIViewController <VKSdkDelegate>

@property (weak, nonatomic) IBOutlet UIButton *vkButton;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UIButton *registrationButton;

@end
