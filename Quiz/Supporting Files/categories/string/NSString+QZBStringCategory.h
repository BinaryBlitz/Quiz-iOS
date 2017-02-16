//
//  NSString+QZBStringCategory.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 09/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QZBStringCategory)
+ (NSString *)endOfWordFromNumber:(NSInteger)number;
+ (NSString *)endOfDayWordFromNumber:(NSInteger)number;

+ (NSString *)firstTwoChars:(NSString *)string;
@end
