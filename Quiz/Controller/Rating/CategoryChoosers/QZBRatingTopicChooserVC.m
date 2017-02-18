#import "QZBRatingTopicChooserVC.h"
#import "QZBRatingMainVC.h"
#import "QZBGameTopic.h"
#import "QZBCategory.h"

@interface QZBRatingTopicChooserVC () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation QZBRatingTopicChooserVC

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [super tableView:tableView numberOfRowsInSection:section] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allCategory"];
    return cell;
  } else {
    NSIndexPath *ip =
        [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    return [super tableView:tableView cellForRowAtIndexPath:ip];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  QZBRatingMainVC *mainVC = nil;
  for (UIViewController *vc in self.navigationController.viewControllers) {
    if ([vc isKindOfClass:[QZBRatingMainVC class]]) {
      mainVC = (QZBRatingMainVC *) vc;
      break;
    }
  }
  if (indexPath.row == 0) {
    mainVC.topic = nil;
    mainVC.category = self.category;
  } else {
    mainVC.topic = self.topics[indexPath.row - 1];
  }
  [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
