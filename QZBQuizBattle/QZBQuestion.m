//
//  QZBQuestion.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBQuestion.h"

@interface QZBQuestion ()

@property (nonatomic, copy) NSString *topic;
@property (nonatomic, copy) NSString *question;
@property (nonatomic, strong) NSArray *answers;
@property (nonatomic, assign) NSUInteger rightAnswer;
@property (assign, nonatomic) NSInteger questionId;

@end

@implementation QZBQuestion

- (instancetype)initWithTopic:(NSString *)topic
                     question:(NSString *)question
                      answers:(NSArray *)answers
                  rightAnswer:(NSUInteger)rightAnswer
                   questionID:(NSInteger)questionID {
    self = [super init];
    if (self) {
        self.topic = topic;
        self.question = question;
        self.answers = answers;
        self.rightAnswer = rightAnswer;
        self.questionId = questionID;
    }
    return self;
}

@end
