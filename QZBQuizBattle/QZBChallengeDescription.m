//
//  QZBChallengeDescription.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 18/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBChallengeDescription.h"
#import "QZBGameTopic.h"
#import "AppDelegate.h"

@interface QZBChallengeDescription()

@property(strong, nonatomic) NSNumber *lobbyID;
@property(copy, nonatomic) NSString *name;
@property(strong, nonatomic) NSNumber *userID;
@property(strong, nonatomic) NSNumber *topicID;
@property(strong, nonatomic) NSString *topicName;
@property(strong, nonatomic) QZBGameTopic *topic;

@end

@implementation QZBChallengeDescription

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.lobbyID = dict[@"id"];
        self.name = dict[@"name"];
        self.topicName = dict[@"topic"];
        self.userID = dict[@"player_id"];
        self.topicID = dict[@"topic_id"];
        
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        
        id context = app.managedObjectContext;

        
        NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"QZBGameTopic" inManagedObjectContext:context];
        QZBGameTopic *topic = (QZBGameTopic *)
        [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
        
        topic.name = dict[@"topic"];
        topic.topic_id = dict[@"topic_id"];
        
        self.topic = topic;
        
        
    }
    return self;
}

@end
