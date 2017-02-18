#import "NSString+PANSStringAdditions.h"

@implementation NSString (PANSStringAdditions)

- (int32_t)FNVhash {
  // A Fowler-Noll-vo hash! (FNV-1a)
  // http://www.isthe.com/chongo/tech/comp/fnv/index.html#FNV-1a
  const char *strptr = [[self uppercaseString] UTF8String];
  int32_t y = (int32_t)2166136261U, x = 0, p = 16777619;
  while (x != (int32_t)[self length]) {
    y ^= strptr[x];
    y *= p;
    x++;
  }
  return y;
}

@end
