#import "QZBEndGameResultScoreCell.h"
#import "NSString+QZBStringCategory.h"

@implementation QZBEndGameResultScoreCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)setResultScore:(NSInteger)score {

  NSString *scoreName = [NSString endOfWordFromNumber:score];
  self.resultLabel.text = [NSString stringWithFormat:@"+%ld %@", score, scoreName];
}

@end
