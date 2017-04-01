#import <UIKit/UIKit.h>
#import <SCLAlertView-Objective-C/SCLAlertView.h> 
#import "UIColor+QZBProjectColors.h"

@interface UIViewController (QZBControllerCategory)

- (void)initStatusbarWithColor:(UIColor *)color;
- (void)showAlertAboutAchievmentWithDict:(NSDictionary *)dict;
- (void)showAlertAboutUnvisibleTopic:(NSString *)topicName;
- (void)showAlertAboutUnabletoPlay;
- (UILabel *)labelForNum:(NSInteger)num inView:(UIView *)view;
- (UITableViewCell *)parentCellForView:(id)theView;
- (void)ignoreIteractions;

@end
