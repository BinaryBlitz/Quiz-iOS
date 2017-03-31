#import "QZBAnswerButton.h"
#import "QZBAnswerTriangle.h"
#import "QZBAnswerCircle.h"


const float fontSize = 19.0;

@implementation QZBAnswerButton

- (UILabel *)answerLabel {
  if (!_answerLabel) {
    [self labelInit];
  }
  return _answerLabel;
}

- (void)labelInit {

  CGRect r = CGRectMake(CGRectGetWidth(self.frame) * 0.05,
      CGRectGetHeight(self.frame) * 0.05,
      CGRectGetWidth(self.frame) * 0.9,
      CGRectGetHeight(self.frame) * 0.9);

  _answerLabel = [[UILabel alloc] initWithFrame:r];

  _answerLabel.textColor = [UIColor whiteColor];
  _answerLabel.textAlignment = NSTextAlignmentCenter;
  _answerLabel.numberOfLines = 0;
  _answerLabel.lineBreakMode = NSLineBreakByClipping;
  _answerLabel.font = [UIFont systemFontOfSize:fontSize];
  _answerLabel.minimumScaleFactor = 0.5;
  _answerLabel.adjustsFontSizeToFitWidth = YES;

  [self addSubview:_answerLabel];

  [self layoutIfNeeded];
}

- (void)setAnswerText:(NSString *)answer {

  NSArray *array = [answer
      componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];

  NSString *maxLenStr = [array firstObject];
  for (NSString *word in array) {
    if (word.length > maxLenStr.length) {
      maxLenStr = word;
    }
  }

  int i;
  for (i = 19; i > 10; i--) {
    CGSize s = [maxLenStr sizeWithAttributes:@{NSFontAttributeName:
        [UIFont systemFontOfSize:i]}];
    if (s.width < self.answerLabel.frame.size.width - 10) {
      break;
    }
  }

  self.answerLabel.font = [UIFont systemFontOfSize:i];
  self.answerLabel.text = answer;
  [self setNeedsLayout];
  [self layoutIfNeeded];
}

- (void)addTriangleLeft {
  CGRect rect =
      CGRectMake(0,
          3.0 * self.frame.size.height / 12.0,
          self.frame.size.height / 12.0,
          self.frame.size.height / 2.0);

  QZBAnswerTriangle *triangle = [[QZBAnswerTriangle alloc] initWithFrame:rect];
  triangle.backgroundColor = [UIColor clearColor];

  [self addSubview:triangle];
}

- (void)addTriangleRight {

  CGRect rect = CGRectMake(CGRectGetWidth(self.frame) - CGRectGetHeight(self.frame) / 12.0,
      3.0 * self.frame.size.height / 12.0,
      self.frame.size.height / 12.0,
      self.frame.size.height / 2.0);

  QZBAnswerTriangle *triangle = [[QZBAnswerTriangle alloc] initWithFrame:rect];

  triangle.transform = CGAffineTransformMakeRotation(M_PI);

  triangle.backgroundColor = [UIColor clearColor];

  [self addSubview:triangle];
}

- (void)addCircleLeft {
  CGFloat diametr = CGRectGetHeight(self.frame) / 5;

  CGRect r = CGRectMake(-diametr / 2, 2 * diametr, diametr, diametr);

  QZBAnswerCircle *circle = [[QZBAnswerCircle alloc] initWithFrame:r];

  circle.backgroundColor = [UIColor clearColor];

  [self addSubview:circle];
}

- (void)addCircleRight {

  CGFloat diametr = CGRectGetHeight(self.frame) / 5;

  CGRect r = CGRectMake(CGRectGetWidth(self.frame) - diametr / 2, 2 * diametr, diametr, diametr);

  QZBAnswerCircle *circle = [[QZBAnswerCircle alloc] initWithFrame:r];

  circle.backgroundColor = [UIColor clearColor];

  [self addSubview:circle];
}

- (void)unshowCircles {
  NSArray *subviews = self.subviews;

  for (UIView *view in subviews) {
    if ([view isKindOfClass:[QZBAnswerCircle class]]) {
      [view removeFromSuperview];
    }
  }
}

- (void)unshowTriangles {
  NSArray *subviews = self.subviews;

  for (UIView *view in subviews) {
    if ([view isKindOfClass:[QZBAnswerTriangle class]]) {
      [view removeFromSuperview];
    }
  }
}

@end
