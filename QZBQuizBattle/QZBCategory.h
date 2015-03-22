//
//  QZBCategory.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 22/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class QZBGameTopic;

@interface QZBCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * category_id;
@property (nonatomic, retain) NSSet *relationToTopic;
@end

@interface QZBCategory (CoreDataGeneratedAccessors)

- (void)addRelationToTopicObject:(QZBGameTopic *)value;
- (void)removeRelationToTopicObject:(QZBGameTopic *)value;
- (void)addRelationToTopic:(NSSet *)values;
- (void)removeRelationToTopic:(NSSet *)values;

@end
