#import <UIKit/UIKit.h>
#import <DFImageManager/DFImageView.h>

@interface QZBCategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet DFImageView *categoryImageView;

@end
