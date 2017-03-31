#import <Foundation/Foundation.h>

@interface NSString (QZBStringCategory)

+ (NSString *)endOfWordFromNumber:(NSInteger)number;
+ (NSString *)endOfDayWordFromNumber:(NSInteger)number;
+ (NSString *)firstTwoChars:(NSString *)string;

@end
