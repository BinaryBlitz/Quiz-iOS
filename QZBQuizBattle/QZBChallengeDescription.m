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
@property(copy, nonatomic)   NSString *name;
@property(strong, nonatomic) NSNumber *userID;
@property(strong, nonatomic) NSNumber *topicID;
@property(strong, nonatomic) NSString *topicName;
@property(strong, nonatomic) QZBGameTopic *topic;

@end

@implementation QZBChallengeDescription

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.lobbyID = dict[@"id"];
        
        if (![dict[@"username"] isEqual:[NSNull null]] && dict[@"username"]){
            self.name = dict[@"username"];
        }else{
            self.name = dict[@"name"];
        }
        
        NSDictionary *topicDict = dict[@"topic"];
     
        self.userID = dict[@"player_id"];
        
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        
        id context = app.managedObjectContext;

        NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"QZBGameTopic" inManagedObjectContext:context];
        QZBGameTopic *topic = (QZBGameTopic *)
        [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
        
        topic.name = topicDict[@"name"];
        topic.topic_id = topicDict[@"id"];
        topic.points = topicDict[@"points"];
        topic.visible = topicDict[@"visible"];
    
        
        self.topic = topic;
        
        self.topicName = topic.name;
        self.topicID = topic.topic_id;
        
    }
    return self;
}

@end
