//
//  QZBRoom.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBRoom : UITableViewCell

@property(strong, nonatomic, readonly) NSNumber *roomID;

- (instancetype)initWithDictionary:(NSDictionary *)d;

@end
