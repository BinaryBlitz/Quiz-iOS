#import <UIKit/UIKit.h>
#import <UAProgressView.h>

@interface QZBEndGamePointsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsNameLabel;
@property (weak, nonatomic) IBOutlet UAProgressView *circleView;


-(void)setCentralLabelWithNimber:(NSInteger)multiplier;
-(void)setScore:(NSUInteger)score;

@end
