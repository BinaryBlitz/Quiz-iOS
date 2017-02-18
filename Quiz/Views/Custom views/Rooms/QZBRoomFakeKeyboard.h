#import <UIKit/UIKit.h>

@interface QZBRoomFakeKeyboard : UIView

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *phrasesButtons;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end
