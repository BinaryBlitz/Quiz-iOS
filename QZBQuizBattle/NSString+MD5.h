//
//  NSString+MD5.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 17/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)

- (NSString *)MD5;
- (NSData *)MD5CharData;

@end