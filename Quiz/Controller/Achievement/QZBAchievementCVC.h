#import <UIKit/UIKit.h>

@interface QZBAchievementCVC : UICollectionViewController

@property (strong, nonatomic) IBOutlet UICollectionView *achivTableView;

- (void)initAchievmentsWithGettedAchievements:(NSArray *)achievs;

@end
