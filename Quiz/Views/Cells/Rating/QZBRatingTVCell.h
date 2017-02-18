#import <UIKit/UIKit.h>

@class QZBUserInRating;

@interface QZBRatingTVCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *numberInRating;
@property (weak, nonatomic) IBOutlet UIImageView *userpic;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (strong, nonatomic, readonly) QZBUserInRating *user;
@property (weak, nonatomic) IBOutlet UIView *myMedalView;

- (void)setCellWithUser:(QZBUserInRating *)user;

@end
