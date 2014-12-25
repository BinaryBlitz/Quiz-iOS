//
//  QZBUser.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QZBUser : NSObject

@property(assign, nonatomic, readonly) NSInteger user_id;

- (instancetype)initWithUserId:(NSInteger)user_id name:(NSString *) name userpicURL:(NSURL *)url;
-(instancetype)initWithId:(NSInteger)user_id;
@end
