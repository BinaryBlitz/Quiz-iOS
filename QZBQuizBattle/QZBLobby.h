//
//  QZBLobby.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 28/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QZBLobby : NSObject

@property (assign, nonatomic, readonly) NSInteger lobbyID;
@property (assign, nonatomic, readonly) NSInteger topicID;
@property (assign, nonatomic, readonly) NSInteger playerID;
@property (assign, nonatomic, readonly) NSInteger queryCount;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end