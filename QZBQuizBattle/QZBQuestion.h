//
//  QZBQuestion.h
//  QZBQuizBattle
//
//  Представлеие вопроса
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QZBQuestion : NSObject

@property (nonatomic, copy, readonly) NSString *topic;
@property (nonatomic, copy, readonly) NSString *question;
@property (nonatomic, strong, readonly) NSArray *answers;//QZBAnswerTextAndID
@property (nonatomic, assign, readonly) NSUInteger rightAnswer;


- (instancetype)initWithTopic:(NSString *)topic
                     question:(NSString *)question
                      answers:(NSArray *) answers
                  rightAnswer:(NSUInteger) rightAnswer;

@end
