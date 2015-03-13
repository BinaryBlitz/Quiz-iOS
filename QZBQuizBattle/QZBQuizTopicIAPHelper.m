//
//  QZBQuizTopicIAPHelper.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 26/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBQuizTopicIAPHelper.h"
#import "QZBServerManager.h"

@interface QZBQuizTopicIAPHelper ()

@property (strong, nonatomic) NSSet *identifiers;

@end

@implementation QZBQuizTopicIAPHelper

+ (QZBQuizTopicIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static QZBQuizTopicIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
//        NSSet * productIdentifiers = [NSSet setWithObjects:
//                                      @"drumih.QZBQuizBattle.smthnew",
//                                      @"drumih.iQuiz.specialGeography",
//                                      @"drumih.iQuiz.specialMath",
//                                      nil];
        
        
        sharedInstance = [[self alloc] init];
    });
    
    
    return sharedInstance;
}







-(void)getTopicIdentifiersFromServerOnSuccess:(void (^)())success
                                    onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    
    [[QZBServerManager sharedManager] GETAvailableInAppPurchasesOnSuccess:^(NSSet *purchases) {
        
      //  self.identifiers = purchases;
        
        [self setProductIdentifiers:purchases];
        
        if(success){
            success();
        }
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        if(failure){
            failure(error, statusCode);
        }
    }];
    
    
}


@end
