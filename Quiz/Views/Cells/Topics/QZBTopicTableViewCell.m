#import "QZBTopicTableViewCell.h"
#import "QZBGameTopic.h"
#import "UIColor+QZBProjectColors.h"
#import "UIColor+QZBColorGenerator.h"
#import "NSString+QZBStringCategory.h"
#import "UIFont+QZBCustomFont.h"
#import "UIView+QZBShakeExtension.h"
#import "NSObject+QZBSpecialCategory.h"
#import "QZBCategory.h"

@interface QZBTopicTableViewCell ()

@property (strong, nonatomic) UILabel *centralLabel;
@property (strong, nonatomic) UIImageView *icon;
@property (assign, nonatomic) BOOL visible;
@property (strong, nonatomic) UIColor *mainCellColor;

@end

@implementation QZBTopicTableViewCell

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  [self.backView addShadowsAllWay];
  [self.underView addShadowsAllWayRasterize];
}

- (void)awakeFromNib {
  // Initialization code
  self.topicProgressView.lineWidth = 4;
  self.topicProgressView.fillOnTouch = NO;
  self.topicProgressView.tintColor = [UIColor lightGreenColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)initWithTopic:(QZBGameTopic *)topic {
  [self.layer setNeedsLayout];

  self.symbolLabel.minimumScaleFactor = 0.5;
  self.symbolLabel.adjustsFontSizeToFitWidth = YES;

  self.topicName.text = topic.name;

  QZBCategory *relationCategory = topic.relationToCategory;

  if (relationCategory) {
    NSString *firstTwoChar = [NSString firstTwoChars:relationCategory.name];

    self.mainCellColor = [UIColor colorForString:relationCategory.name];
    self.symbolsView.backgroundColor = self.mainCellColor;
    self.symbolLabel.text = firstTwoChar;
  }

  NSInteger level = 0;
  float progress = 0.0;

  [NSObject calculateLevel:&level
             levelProgress:&progress
                 fromScore:[topic.points integerValue]];

  [self initCircularProgressWithLevel:level
                             progress:progress
                              visible:[topic.visible boolValue]];
}

- (void)initCircularProgressWithLevel:(NSInteger)level
                             progress:(float)progress
                              visible:(BOOL)visible {
  self.visible = visible;

  if (!visible) {
    self.topicProgressView.tintColor = [UIColor clearColor];
    self.topicProgressView.centralView = self.icon;
    self.icon.image = [UIImage imageNamed:@"lockIcon"];
    return;
  }

  if (progress > 0 || level > 0) {
    self.topicProgressView.centralView = self.centralLabel;
    self.topicProgressView.tintColor = [UIColor lightGreenColor];
    self.centralLabel.text = [NSString stringWithFormat:@"%ld", (long) level];
    self.topicProgressView.progress = progress;
    if (self.mainCellColor) {
      self.topicProgressView.tintColor = self.mainCellColor;
    }
  } else {
    self.topicProgressView.tintColor = [UIColor clearColor];
    self.topicProgressView.centralView = self.icon;
    self.icon.image = [UIImage imageNamed:@"downIcon"];
  }
}

- (void)setSymbolsWithText:(NSString *)symbols {

  self.symbolLabel.text = symbols;
}

- (UILabel *)centralLabel {
  if (!_centralLabel) {
    _centralLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(0,
            0,
            CGRectGetWidth(self.topicProgressView.frame) / 2.0,
            CGRectGetWidth(self.topicProgressView.frame) / 2.0)];

    _centralLabel.textColor = [UIColor lightGrayColor];
    _centralLabel.textAlignment = NSTextAlignmentCenter;
    _centralLabel.adjustsFontSizeToFitWidth = YES;

    _centralLabel.font = [UIFont museoFontOfSize:15];
  }
  return _centralLabel;
}

- (UIImageView *)icon {
  if (!_icon) {
    _icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
  }
  return _icon;
}

- (UIColor *)colorForText:(NSString *)text {
  return arc4random() % 10 > 5 ? [UIColor lightRedColor] : [UIColor lightGreenColor];
}

@end
