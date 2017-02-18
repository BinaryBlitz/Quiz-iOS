#import <UIKit/UIKit.h>

@class QZBRoom;

@interface QZBRoomCell : UITableViewCell

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *namesLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *topicsNamesLabels;
@property (weak, nonatomic) IBOutlet UILabel *usersCountLabel;

- (void)configureCellWithRoom:(QZBRoom *)room;

@end
