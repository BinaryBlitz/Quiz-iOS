#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@interface QZBImageViewerVC : UIViewController  <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userPicImageView;

-(void)configureWithUser:(id<QZBUserProtocol>)user;

@end
