#import "UIColor+PAUIColorAdditions.h"
#import "NSString+PANSStringAdditions.h"


//#import "PAUtility.h"

int const kBitPairsTakenFromHash = 8; // Amount of pairs taken from hash.

CGFloat const kBrightnessLight = 0.95f;
CGFloat const kBrightnessDark = 0.75f;

CGFloat const kSaturationRangeStart = 0.5f;
CGFloat const kSaturationRangeEnd = 1.0f;

typedef struct PATwoNSUIntegers {
  NSUInteger first;
  NSUInteger second;
} PATwoNSUIntegers;

@implementation UIColor (PAUIColorAdditions)

#pragma mark - Creating color from string.

+ (instancetype)colorWithString:(NSString *)string
                  andBrightness:(CGFloat)brightness {
 // NSLog(@"STRING: %@", string);
  return [self colorWithHash:(NSUInteger)string.FNVhash brightness:brightness];
}

PATwoNSUIntegers evenAndOddBitsDivided(NSUInteger hash);
+ (instancetype)colorWithHash:(NSUInteger)hash brightness:(CGFloat)brightness {

  PATwoNSUIntegers hueAndSat = evenAndOddBitsDivided(hash);
  CGFloat max = ((1 << kBitPairsTakenFromHash) - 1);
  CGFloat hue = (CGFloat)hueAndSat.first / max;
  CGFloat range = kSaturationRangeEnd - kSaturationRangeStart;
  CGFloat saturation = ((CGFloat)hueAndSat.second / max) * range;
  saturation += kSaturationRangeStart;
  return [UIColor colorWithHue:hue
                    saturation:saturation
                    brightness:brightness
                         alpha:1.0];
}

PATwoNSUIntegers evenAndOddBitsDivided(NSUInteger hash) {
  PATwoNSUIntegers answer;
  answer.first = 0;
  answer.second = 0;
  hash &= ((1 << kBitPairsTakenFromHash * 2) - 1);
 // NSLog(@"HASH: %lu", (unsigned long)hash);
  for (int i = 0; i < kBitPairsTakenFromHash; ++i) {
    answer.first <<= 1;
    answer.second <<= 1;
    answer.first |= hash & 1;
    // answer.first = answer.first | (hash & 1);
    answer.second |= (hash & 2) >> 1;
    hash >>= 2;
  }
 // NSLog(@"FIRST: %lu", (unsigned long)answer.first);
 // NSLog(@"SECOND: %lu", (unsigned long)answer.second);
  return answer;
}

#pragma mark - Creating bright and dark colors.

+ (instancetype)colorLightForFirstName:(NSString *)firstName
                            secondName:(NSString *)secondName {
  return
      [self colorLightWithString:[NSString stringWithFormat:@"%@ %@", firstName,
                                                            secondName]];
}

+ (instancetype)colorDarkForFirstName:(NSString *)firstName
                           secondName:(NSString *)secondName {
  return
      [self colorDarkWithString:[NSString stringWithFormat:@"%@ %@", firstName,
                                                           secondName]];
}

+ (instancetype)colorDarkWithString:(NSString *)string {
  return [self colorWithString:string andBrightness:kBrightnessDark];
}

+ (instancetype)colorLightWithString:(NSString *)string {
  return [self colorWithString:string andBrightness:kBrightnessLight];
}

#pragma mark - Creating color from integer.

+ (instancetype)colorWithIntegerRGB:(NSInteger)rgbValue {
  return [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0f
                         green:((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0f
                          blue:((CGFloat)(rgbValue & 0xFF)) / 255.0f
                         alpha:1.0];
}

@end
