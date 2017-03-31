#import "UIColor+QZBColorGenerator.h"
#import "UIColor+PAUIColorAdditions.h"

@implementation UIColor (QZBColorGenerator)

+ (UIColor *)colorForString:(NSString *)string {
  return [UIColor colorLightWithString:string];
}


@end
