#import "NSString+QZBStringCategory.h"

@implementation NSString (QZBStringCategory)

+ (NSString *)endOfWordFromNumber:(NSInteger)number {
  NSInteger num = number % 100;

  if (num > 20) {
    num = num % 10;
  }
  if (num == 0) {
    return @"очков";
  } else if (num >= 5 && num <= 20) {
    return @"очков";
  } else if (num == 1) {
    return @"очко";
  } else {
    return @"очка";
  }
}

+ (NSString *)endOfDayWordFromNumber:(NSInteger)number {

  if (number == 1) {
    return @"день";
  } else if (number >= 2 && number <= 4) {
    return @"дня";
  } else {
    return @"дней";
  }
}

+ (NSString *)firstTwoChars:(NSString *)string {
  NSString *fullString = string;
  NSString *prefix = nil;

  if ([fullString length] >= 2)
    prefix = [fullString substringToIndex:2];
  else
    prefix = fullString;

  return prefix;
}

@end
