//
//  QZBGameTopic.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 24/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QZBGameTopic : NSObject

@property(copy,   nonatomic, readonly) NSString *name;
@property(assign, nonatomic, readonly) NSInteger topic_id;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
