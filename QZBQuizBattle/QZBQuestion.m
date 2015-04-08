//
//  QZBQuestion.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBQuestion.h"
#import "QZBAnswerTextAndID.h"

@interface QZBQuestion ()

@property (nonatomic, copy) NSString *topic;
@property (nonatomic, copy) NSString *question;
@property (nonatomic, strong) NSArray *answers;
@property (nonatomic, assign) NSUInteger rightAnswer;
@property (assign, nonatomic) NSInteger questionId;
@property (strong, nonatomic) NSURL *imageURL;

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

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        
        
        NSDictionary *questDict = [dict objectForKey:@"question"];
        NSString *questText = [questDict objectForKey:@"content"];
        NSInteger questionID = [[dict objectForKey:@"id"] integerValue];
        NSInteger correctAnswer = -1;
        NSArray *answersDicts = [questDict objectForKey:@"answers"];
        NSMutableArray *answers = [NSMutableArray array];
        
        // NSInteger i = 0;
        for (NSDictionary *answDict in answersDicts) {
            // NSLog(@"%@", answDict);
            
            NSString *textOfAnswer = [answDict objectForKey:@"content"];
            NSInteger answerID = [[answDict objectForKey:@"id"] integerValue];
            QZBAnswerTextAndID *answerWithId =
            [[QZBAnswerTextAndID alloc] initWithText:textOfAnswer answerID:answerID];
            
            [answers addObject:answerWithId];
            NSNumber *isRight = [answDict objectForKey:@"correct"];
            if ([isRight isEqual:@(1)]) {
                correctAnswer = answerID;  //[[answDict objectForKey:@"id"] integerValue];
            }
            //  i++;
        }
        
        //перемешивает ответы в массиве(json приходит так, что правильный всегда
        //первый
        NSUInteger count = [answers count];
        for (NSUInteger i = 0; i < count; ++i) {
            NSUInteger nElements = count - i;
            NSUInteger n = (arc4random() % nElements) + i;
            [answers exchangeObjectAtIndex:i withObjectAtIndex:n];
        }

        self.answers = answers;
        self.question = questText;
        self.rightAnswer = correctAnswer;
        self.questionId = questionID;
        
        
    }
    return self;
}

@end
