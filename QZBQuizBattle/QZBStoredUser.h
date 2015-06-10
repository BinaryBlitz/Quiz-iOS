//
//  QZBStoredUser.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface QZBStoredUser : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSString * imageURLAsString;
@property (nonatomic, retain) NSNumber * unreadedCount;

@end
