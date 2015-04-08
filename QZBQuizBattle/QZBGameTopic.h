//
//  QZBGameTopic.h
//  
//
//  Created by Andrey Mikhaylov on 08/04/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class QZBCategory;

@interface QZBGameTopic : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSNumber * topic_id;
@property (nonatomic, retain) QZBCategory *relationToCategory;

@end
