#import "NSDate+QZBDateCategory.h"
#import <NSDate+DateTools.h>

@implementation NSDate (QZBDateCategory)

+ (NSDate *)customDateFromString:(NSString *)dateAsString {

  NSDateFormatter *df = [[NSDateFormatter alloc] init];

  df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  [df setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
  df.locale = [NSLocale systemLocale];

  return [df dateFromString:dateAsString];
}

+ (NSString *)redableTimeFromDate:(NSDate *)timestamp {
  // NSDate *timestamp = [[self class] customDateFromString:dateAsString];

  NSString *minutes = [timestamp minute] < 10
      ? [NSString stringWithFormat:@"0%ld", [timestamp minute]]
      : [NSString stringWithFormat:@"%ld", [timestamp minute]];
  return [NSString stringWithFormat:@"%ld:%@", [timestamp hour], minutes];
}

@end
