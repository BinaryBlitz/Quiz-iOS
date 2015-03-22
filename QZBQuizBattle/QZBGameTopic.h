//
//  QZBGameTopic.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 22/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class QZBCategory;

@interface QZBGameTopic : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * topic_id;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) QZBCategory *relationToCategory;

@end
