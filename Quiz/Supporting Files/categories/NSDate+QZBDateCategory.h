#import <Foundation/Foundation.h>

@interface NSDate (QZBDateCategory)

+ (NSDate *)customDateFromString:(NSString *)dateAsString;
+ (NSString *)redableTimeFromDate:(NSDate *)timestamp;

@end
