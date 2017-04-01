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
}

@end
