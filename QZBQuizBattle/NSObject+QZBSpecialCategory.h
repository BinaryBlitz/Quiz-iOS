//
//  NSObject+QZBSpecialCategory.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (QZBSpecialCategory)

+(void)calculateLevel:(NSInteger *)level levelProgress:(float *)levelProgress fromScore:(NSInteger)score;

@end
