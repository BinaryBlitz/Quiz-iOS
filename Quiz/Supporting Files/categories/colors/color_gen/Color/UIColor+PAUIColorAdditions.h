#import <UIKit/UIKit.h>

@interface UIColor (PAUIColorAdditions)

+ (instancetype)colorWithString:(NSString *)string
                  andBrightness:(CGFloat)brightness;

+ (instancetype)colorLightForFirstName:(NSString *)firstName
                            secondName:(NSString *)secondName;

+ (instancetype)colorDarkForFirstName:(NSString *)firstName
                           secondName:(NSString *)secondName;

+ (instancetype)colorLightWithString:(NSString *)string;

+ (instancetype)colorDarkWithString:(NSString *)string;

+ (instancetype)colorWithIntegerRGB:(NSInteger)rgbValue;

@end
