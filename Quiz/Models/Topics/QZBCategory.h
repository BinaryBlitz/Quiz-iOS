//
//  QZBCategory.h
//  
//
//  Created by Andrey Mikhaylov on 08/04/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class QZBGameTopic;

@interface QZBCategory : NSManagedObject

@property (nonatomic, retain) NSData *background;
@property (nonatomic, retain) NSData *banner;
@property (nonatomic, retain) NSNumber *category_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *banner_url;
@property (nonatomic, retain) NSString *background_url;
@property (nonatomic, retain) NSSet *relationToTopic;
@end

@interface QZBCategory (CoreDataGeneratedAccessors)

- (void)addRelationToTopicObject:(QZBGameTopic *)value;

- (void)removeRelationToTopicObject:(QZBGameTopic *)value;

- (void)addRelationToTopic:(NSSet *)values;

- (void)removeRelationToTopic:(NSSet *)values;

@end
