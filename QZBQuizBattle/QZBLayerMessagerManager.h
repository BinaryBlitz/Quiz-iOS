//
//  QZBLayerMessagerManager.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 03/08/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LYRClient;

@interface QZBLayerMessagerManager : NSObject

@property (nonatomic, readonly) LYRClient *layerClient;

- (void)connectWithCompletion:(void (^)(BOOL success, NSError * error))completion;

+ (instancetype)sharedInstance;


-(NSInteger)unreadedCount;

-(NSArray *)conversations;

-(void)logOut;

-(void)logOutWithCompletion:(void (^)(BOOL success, NSError *error))completion;

@end
