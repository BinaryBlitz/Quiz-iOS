//
//  QZBQuizTopicIAPHelper.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 26/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBIAPHelper.h"

@interface QZBQuizTopicIAPHelper : QZBIAPHelper

+ (QZBQuizTopicIAPHelper *)sharedInstance;
-(void)getTopicIdentifiersFromServerOnSuccess:(void (^)())success
                                    onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;




@end
