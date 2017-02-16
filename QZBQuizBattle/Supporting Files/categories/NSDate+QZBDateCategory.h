//
//  NSDate+QZBDateCategory.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/10/15.
//  Copyright © 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (QZBDateCategory)

+ (NSDate *)customDateFromString:(NSString *)dateAsString;
+ (NSString *)redableTimeFromDate:(NSDate *)timestamp;

@end
