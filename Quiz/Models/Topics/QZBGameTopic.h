#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class QZBCategory;

@interface QZBGameTopic : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSNumber * topic_id;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) NSNumber * paid;
@property (nonatomic, retain) QZBCategory *relationToCategory;

@end
