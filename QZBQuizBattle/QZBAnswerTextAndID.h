//
//  QZBAnswerTextAndID.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QZBAnswerTextAndID : NSObject

@property (copy, nonatomic, readonly) NSString *answerText;
@property (assign, nonatomic, readonly) NSInteger answerID;

- (instancetype)initWithText:(NSString *)answer answerID:(NSInteger)answerID;

@end
