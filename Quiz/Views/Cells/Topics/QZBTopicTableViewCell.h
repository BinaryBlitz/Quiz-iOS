#import <UIKit/UIKit.h>
#import <UAProgressView.h> 

@class QZBGameTopic;

@interface QZBTopicTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *topicName;
@property (weak, nonatomic) IBOutlet UAProgressView *topicProgressView;
@property (assign, nonatomic, readonly) BOOL visible;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *underView;
@property (weak, nonatomic) IBOutlet UIView *symbolsView;
@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;

-(void)initCircularProgressWithLevel:(NSInteger)level
                            progress:(float)progress
                             visible:(BOOL)visible;

-(void)initWithTopic:(QZBGameTopic *)topic;

@end
