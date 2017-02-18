#import "UIColor+QZBColorGenerator.h"
#import "UIColor+PAUIColorAdditions.h"

@implementation UIColor (QZBColorGenerator)

+ (UIColor *)colorForString:(NSString *)string {

  // NSUInteger toSearch = string.hash%9;

  // NSLog(@"%ld", toSearch);

//    UIColor *color = nil;
//    
//    switch (toSearch) {
//        case 0:
//            color = [UIColor ultralightGreenColor];
//            break;
//        case 1:
//            color = [UIColor lightRedColor];
//            break;
//        case 2:
//            color = [UIColor lightBlueColor];
//            break;
//        case 3:
//            color = [UIColor lightButtonColor];
//            break;
//        case 4:
//            color = [UIColor lightPincColor];
//            break;
//        case 5:
//            color = [UIColor ultralightGreenColor];
//            break;
//        case 6:
//            color = [UIColor challengedColor];
//            break;
//        case 7:
//            color = [UIColor friendsLightGreyColor];
//            break;
//        case 8:
//            color = [UIColor brightRedColor];
//            break;
//        default:
//            color = [UIColor lightGreenColor];
//            break;
//    }

  UIColor *color = [UIColor colorLightWithString:string];

  return color;
}


@end
