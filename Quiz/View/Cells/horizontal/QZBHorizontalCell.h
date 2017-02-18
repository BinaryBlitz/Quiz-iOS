#import <UIKit/UIKit.h>


@interface QZBHorizontalCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *horizontalTabelView;

@property(copy, nonatomic)NSString *buttonTitle;



-(void)setSomethingArray:(NSArray *)somethingArray;

@end
