//
//  QZBProduct.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 14/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QZBProduct : NSObject

@property (copy,   nonatomic, readonly) NSString *identifier;
@property (strong, nonatomic, readonly) NSNumber *topicID;
@property (assign, nonatomic, readonly) BOOL isPurchased;

- (instancetype)initWhithDictionary:(NSDictionary *) dict;

@end
