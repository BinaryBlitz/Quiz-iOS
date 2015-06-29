//
//  QZBSettingTopicProtocol.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 29/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QZBGameTopic;

@protocol QZBSettingTopicProtocol <NSObject>

-(void)setUserTopic:(QZBGameTopic *)topic;

@end
