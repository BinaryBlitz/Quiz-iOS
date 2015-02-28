//
//  QZBQuizTopicIAPHelper.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 26/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBQuizTopicIAPHelper.h"

@implementation QZBQuizTopicIAPHelper

+ (QZBQuizTopicIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static QZBQuizTopicIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"drumih.QZBQuizBattle.smthnew",
                                      
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}


@end
