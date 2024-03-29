#import "QZBEndGameProgressCell.h"
#import <UAProgressView.h>
#import "UIColor+QZBProjectColors.h"
#import "NSObject+QZBSpecialCategory.h"


@interface QZBEndGameProgressCell ()

@property (strong, nonatomic) UILabel *centralLabel;
@property (assign, nonatomic) NSInteger currentLevel;
@property (assign, nonatomic) NSInteger resultLevel;
@property (assign, nonatomic) float resultProgress;

@end

@implementation QZBEndGameProgressCell

- (void)initCell {
  CGRect r = CGRectMake(0,
      0,
      CGRectGetHeight(self.circularOldProgress.frame) / 2,
      CGRectGetHeight(self.circularOldProgress.frame) / 2);

  self.centralLabel = [[UILabel alloc] initWithFrame:r];

  self.centralLabel.font = [UIFont boldSystemFontOfSize:40];
  self.centralLabel.textColor = [UIColor whiteColor];
  self.centralLabel.adjustsFontSizeToFitWidth = YES;
  self.centralLabel.textAlignment = NSTextAlignmentCenter;
  self.centralLabel.numberOfLines = 2;

  self.circularBackgroundProgress.centralView = self.centralLabel;

  self.circularProgress.lineWidth = 11;
  self.circularOldProgress.lineWidth = 11;
  self.circularProgress.borderWidth = 0;
  self.circularOldProgress.borderWidth = 0;
  self.circularBackgroundProgress.lineWidth = 10;
  self.circularBackgroundProgress.borderWidth = 0;
  self.circularBackgroundProgress.progress = 0.999999;

  self.circularOldProgress.fillOnTouch = NO;
  self.circularProgress.fillOnTouch = NO;
  self.circularBackgroundProgress.fillOnTouch = NO;

  self.circularBackgroundProgress.tintColor = [UIColor whiteColor];

  [self bringSubviewToFront:self.circularProgress];
  [self sendSubviewToBack:self.circularBackgroundProgress];

  self.circularOldProgress.tintColor = [UIColor lightBlueColor];
  self.circularProgress.tintColor = [UIColor lightGreenColor];
  self.circularProgress.animationDuration = 2.0;
}

- (void)initCellWithBeginScore:(NSInteger)beginScore {

  [self initCell];

  NSInteger beginLevel = 0;
  float beginProgress = 0.0;

  [NSObject calculateLevel:&beginLevel
             levelProgress:&beginProgress
                 fromScore:beginScore];
  self.centralLabel.attributedText = [self stringWithNumber:beginLevel];//[NSString stringWithFormat:@"%ld", (long)beginLevel];
  self.circularOldProgress.progress = beginProgress;
}

- (void)moveProgressFromBeginScore:(NSInteger)beginScore toEndScore:(NSInteger)endScore {

  NSInteger beginLevel = 0;
  float beginProgress = 0.0;
  NSInteger resultLevel = 0;
  float resultProgress = 0.0;

  [NSObject calculateLevel:&beginLevel
             levelProgress:&beginProgress
                 fromScore:beginScore];

  self.centralLabel.attributedText = [self stringWithNumber:beginLevel];

  [self.circularProgress setProgress:beginProgress animated:NO];

  [NSObject calculateLevel:&resultLevel
             levelProgress:&resultProgress
                 fromScore:endScore];

  self.resultLevel = resultLevel;
  self.currentLevel = beginLevel;
  self.resultProgress = resultProgress;

  self.circularOldProgress.progress = beginProgress;
  self.circularProgress.progress = beginProgress;

  [self turningCircularView];
}

- (NSAttributedString *)stringWithNumber:(NSInteger)level {

  NSString *string = [NSString stringWithFormat:@"%ld \nуровень", (long) level];

  NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]
      initWithString:string];

  NSRange r = {.location = string.length - 7, .length = 7};

  [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:r];

  return attrString;
}

- (void)turningCircularView {
  self.centralLabel.attributedText = [self stringWithNumber:self.currentLevel];

  if (self.currentLevel == self.resultLevel) {
    [self.circularProgress setProgress:(CGFloat) self.resultProgress animated:YES];
    return;
  } else if (self.currentLevel < self.resultLevel) {

    [self.circularProgress setProgress:0.9999 animated:YES];
    CFTimeInterval time = self.circularProgress.animationDuration + 0.1;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (time * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{

          if (self.circularOldProgress.progress != 0) {
            self.circularOldProgress.progress = 0.0;
          }
          self.circularProgress.progress = 0.0;
          self.currentLevel++;
          [self turningCircularView];
        });
  }
}


@end
