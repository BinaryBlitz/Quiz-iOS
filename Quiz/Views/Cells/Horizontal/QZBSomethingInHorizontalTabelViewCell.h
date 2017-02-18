#import <UIKit/UIKit.h>

@interface QZBSomethingInHorizontalTabelViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *picture;
@property (strong, nonatomic) UILabel *name;

- (void)setName:(NSString *)name picURLAsString:(NSString *)URLString;
- (void)setName:(NSString *)name picture:(UIImage *)image;
- (void)setName:(NSString *)name picURL:(NSURL *)picURL;

@end
