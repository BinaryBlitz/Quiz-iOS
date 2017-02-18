#import "UIFont+QZBCustomFont.h"

@implementation UIFont (QZBCustomFont)
+(UIFont *)museoFontOfSize:(CGFloat)fontSize{
    return [UIFont fontWithName:@"MuseoSansCyrl-500" size:fontSize];
}

+(UIFont *)boldMuseoFontOfSize:(CGFloat)fontSize{
    
    return [UIFont fontWithName:@"MuseoSansCyrl-700" size:fontSize];
}
@end
