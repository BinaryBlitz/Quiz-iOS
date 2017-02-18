#import <UIKit/UIKit.h>

@interface QZBEndGameResultScoreCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

-(void)setResultScore:(NSInteger)score;

@end
