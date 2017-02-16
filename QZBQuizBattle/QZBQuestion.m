//
//  QZBQuestion.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBQuestion.h"
#import "QZBAnswerTextAndID.h"
#import "QZBServerManager.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

//image manager
#import <DFImageManager/DFImageManager.h>
#import <DFImageManager/DFImageRequestOptions.h>
#import <DFImageManager/DFURLImageFetcher.h>
#import <DFImageManager/DFImageRequest.h>
#import <DFImageManager/DFImageCaching.h>
#import <DFImageCache.h>
#import "QZBGameTopic.h"
#import "MagicalRecord/MagicalRecord.h"


@interface QZBQuestion ()

//@property (nonatomic, copy) NSString *topic;
@property (nonatomic, copy) NSString *question;
@property (nonatomic, strong) NSArray *answers;
@property (nonatomic, assign) NSUInteger rightAnswer;
@property (assign, nonatomic) NSInteger questionId;
@property (strong, nonatomic) NSURL *imageURL;
@property (assign, nonatomic) NSInteger questionIDForReport;
@property (strong, nonatomic) QZBGameTopic *topic;

@end

@implementation QZBQuestion

- (instancetype)initWithTopic:(NSString *)topic
                     question:(NSString *)question
                      answers:(NSArray *)answers
                  rightAnswer:(NSUInteger)rightAnswer
                   questionID:(NSInteger)questionID {
  self = [super init];
  if (self) {
    //  self.topic = topic;
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
    if([questDict objectForKey:@"id"]){
      self.questionIDForReport = [[questDict objectForKey:@"id"] integerValue];
    }


    if(questDict[@"topic_id"] && ![questDict[@"topic_id"] isEqual:[NSNull null]]) {
      QZBGameTopic *topic = [QZBGameTopic MR_findFirstByAttribute:@"topic_id"
                                                        withValue:questDict[@"topic_id"]];
      if(topic){
        self.topic = topic;
      }
    }

    NSInteger correctAnswer = -1;
    NSArray *answersDicts = [questDict objectForKey:@"answers"];
    NSMutableArray *answers = [NSMutableArray array];

    // NSInteger i = 0;
    for (NSDictionary *answDict in answersDicts) {

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

    NSString *imageURLAsString = questDict[@"image_url"];

    if(imageURLAsString && ![imageURLAsString isEqual:[NSNull null]]){

      NSString *urlStr = [QZBServerBaseUrl stringByAppendingString:imageURLAsString];
      NSURL *imgURL = [NSURL URLWithString:urlStr];

      DFMutableImageRequestOptions *options = [DFMutableImageRequestOptions new];

      options.userInfo = @{ DFURLRequestCachePolicyKey : @(NSURLRequestReturnCacheDataElseLoad )
                            };

      options.priority = DFImageRequestPriorityHigh;
      DFImageRequest *request = [DFImageRequest requestWithResource:imgURL targetSize:CGSizeZero contentMode:DFImageContentModeAspectFill options:options];

//      [[DFImageManager sharedManager] requestImageForRequest:request completion:^(UIImage *image, NSDictionary *info) {}];
      [[DFImageManager sharedManager] imageTaskForRequest:request completion:nil];



      self.imageURL = imgURL;
    }else{
      self.imageURL = nil;
    }


    self.answers = answers;
    self.question = questText;
    self.rightAnswer = correctAnswer;
    self.questionId = questionID;


  }
  return self;
}






@end
