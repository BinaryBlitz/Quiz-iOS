//
//  QZBQuizIAPHelper.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBQuizIAPHelper.h"


@implementation QZBQuizIAPHelper

+ (QZBQuizIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static QZBQuizIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"drumih.QZBQuizBattle.twiceBooster",
                                      @"drumih.QZBQuizBattle.tripleBooster",
                                      nil];
        
        
        
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}





@end
