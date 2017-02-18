#import <UIKit/UIKit.h>

@class QZBRoom;
@interface QZBRoomCell : UITableViewCell
//@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
//@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
//@property (weak, nonatomic) IBOutlet UILabel *topicsDescriptionLabel;

//@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *usersDescriptionsLabels;
//
//@property (weak, nonatomic) IBOutlet UILabel *namesLabels;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *namesLabels;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *topicsNamesLabels;




@property (weak, nonatomic) IBOutlet UILabel *usersCountLabel;

- (void)configureCellWithRoom:(QZBRoom *)room;

@end
