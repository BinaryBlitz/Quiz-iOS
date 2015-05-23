//
//  UIFont+QZBCustomFont.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 23/05/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "UIFont+QZBCustomFont.h"

@implementation UIFont (QZBCustomFont)
+(UIFont *)museoFontOfSize:(CGFloat)fontSize{
    return [UIFont fontWithName:@"MuseoSansCyrl-500" size:fontSize];
}

+(UIFont *)boldMuseoFontOfSize:(CGFloat)fontSize{
    
    return [UIFont fontWithName:@"MuseoSansCyrl-700" size:fontSize];
}
@end
