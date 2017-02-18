#import <UIKit/UIKit.h>

@interface QZBRoomUsersView : UIView

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *nameLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *usersScores;

@end
