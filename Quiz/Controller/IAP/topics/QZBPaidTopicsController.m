#import "QZBPaidTopicsController.h"
#import "MagicalRecord/MagicalRecord.h"
#import "QZBGameTopic.h"
#import "UIColor+QZBProjectColors.h"

@interface QZBPaidTopicsController ()

@end

@implementation QZBPaidTopicsController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.topics = [QZBGameTopic MR_findByAttribute:@"paid" withValue:@(YES)];
  self.title = @"Платные темы";
  [self.topicTableView reloadData];
  self.topicTableView.backgroundColor = [UIColor veryDarkGreyColor];

  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
