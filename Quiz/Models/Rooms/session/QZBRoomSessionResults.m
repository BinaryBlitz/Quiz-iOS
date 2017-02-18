#import "QZBRoomSessionResults.h"

//#import "QZBRoom.h"
//#import "QZBRoomWorker.h"
//#import "QZBUserWithTopic.h"
//
@interface QZBRoomSessionResults ()

@property (strong, nonatomic) NSArray *users;

@property (strong, nonatomic) NSDictionary *resDict;
@end

@implementation QZBRoomSessionResults

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self) {

    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    NSArray *roomQuests = dict[@"room_questions"];

    for (NSDictionary *questDict in roomQuests) {
      NSDictionary *tmpDict = questDict[@"room_question"];

      NSArray *questAnswers = tmpDict[@"room_answers"];

      for (NSDictionary *userAnswerDict in questAnswers) {
        BOOL isRight = [userAnswerDict[@"is_correct"] boolValue];
        NSNumber *userID = userAnswerDict[@"player_id"];
        NSInteger time = [userAnswerDict[@"time"] integerValue];

        NSInteger points = [self pointsForTime:time correct:isRight];

        if (resultDict[userID]) {
          NSInteger oldPoints = [resultDict[userID] integerValue];

          resultDict[userID] = @(oldPoints + points);
        } else {
          resultDict[userID] = @(points);
        }

      }

    }

    self.resDict = [NSDictionary dictionaryWithDictionary:resultDict];
    NSLog(@"res dict %@", self.resDict);
  }
  return self;
}

- (NSNumber *)pointsForUserWithID:(NSNumber *)userID {

  return self.resDict[userID];

}

- (NSInteger)pointsForTime:(NSInteger)time correct:(BOOL)correct {

  if (correct) {
    return 20 - time;
  } else {
    return 0;
  }

}



//015-07-20 16:14:00:809 QZBQuizBattle[4210:807] session results {
//    "created_at" = "2015-07-20T13:12:39.262Z";
//    id = 155;
//    "room_questions" =     (
//                            {
//                                "room_question" =             {
//                                    id = 972;
//                                    question =                 {
//                                        answers =                     (
//                                                                       {
//                                                                           content = "C 2011 \U0433\U043e\U0434\U0430.";
//                                                                           correct = 1;
//                                                                           id = 44993;
//                                                                       },
//                                                                       {
//                                                                           content = "C 2012 \U0433\U043e\U0434\U0430.";
//                                                                           correct = 0;
//                                                                           id = 44994;
//                                                                       },
//                                                                       {
//                                                                           content = "\U0421 2010 \U0433\U043e\U0434\U0430.";
//                                                                           correct = 0;
//                                                                           id = 44995;
//                                                                       },
//                                                                       {
//                                                                           content = "C 2014 \U0433\U043e\U0434\U0430.";
//                                                                           correct = 0;
//                                                                           id = 44996;
//                                                                       }
//                                                                       );
//                                        content = "\U0421 \U043a\U0430\U043a\U043e\U0433\U043e \U0433\U043e\U0434\U0430 \U0432\U044b\U043f\U0443\U0441\U043a\U0430\U0435\U0442\U0441\U044f \U0441\U0435\U0440\U0438\U0439\U043d\U044b\U0439 \U0430\U0432\U0442\U043e\U043c\U043e\U0431\U0438\U043b\U044c \"Koenigsegg Agera R\"?";
//                                        "image_url" = "/uploads/question/image/11249/Koenigsegg_Agera_R_-_Flickr_-_andrewbasterfield.jpg";
//                                    };
//                                    "room_answers" =                 (
//                                                                      {
//                                                                          id = 1079;
//                                                                          "is_correct" = 1;
//                                                                          "player_id" = 64;
//                                                                          time = 4;
//                                                                      },
//                                                                      {
//                                                                          id = 1078;
//                                                                          "is_correct" = 1;
//                                                                          "player_id" = 7;
//                                                                          time = 2;
//                                                                      }
//                                                                      );
//                                };
//                            },
//                            {
//                                "room_question" =             {
//                                    id = 971;
//                                    question =                 {
//                                        answers =                     (
//                                                                       {
//                                                                           content = "Dodge ";
//                                                                           correct = 1;
//                                                                           id = 30173;
//                                                                       },
//                                                                       {
//                                                                           content = Lada;
//                                                                           correct = 0;
//                                                                           id = 30174;
//                                                                       },
//                                                                       {
//                                                                           content = "Lexus ";
//                                                                           correct = 0;
//                                                                           id = 30175;
//                                                                       },
//                                                                       {
//                                                                           content = "Infinity ";
//                                                                           correct = 0;
//                                                                           id = 30176;
//                                                                       }
//                                                                       );
//                                        content = "\U041a\U0430\U043a\U043e\U0439 \U043c\U0430\U0440\U043a\U0435 \U043f\U0440\U0438\U043d\U0430\U0434\U043b\U0435\U0436\U0438\U0442 \U0434\U0430\U043d\U043d\U044b\U0439 \U043b\U043e\U0433\U043e\U0442\U0438\U043f? ";
//                                        "image_url" = "/uploads/question/image/7544/image.jpg";
//                                    };
//                                    "room_answers" =                 (
//                                                                      {
//                                                                          id = 1081;
//                                                                          "is_correct" = 1;
//                                                                          "player_id" = 64;
//                                                                          time = 3;
//                                                                      },
//                                                                      {
//                                                                          id = 1080;
//                                                                          "is_correct" = 1;
//                                                                          "player_id" = 7;
//                                                                          time = 1;
//                                                                      }
//                                                                      );
//                                };
//                            },
//                            {
//                                "room_question" =             {
//                                    id = 970;
//                                    question =                 {
//                                        answers =                     (
//                                                                       {
//                                                                           content = "\U041a\U043e\U043b\U0438\U0447\U0435\U0441\U0442\U0432\U043e \U0446\U0438\U043b\U0438\U043d\U0434\U0440\U043e\U0432.";
//                                                                           correct = 1;
//                                                                           id = 43869;
//                                                                       },
//                                                                       {
//                                                                           content = "\U041a\U043e\U043b\U0438\U0447\U0435\U0441\U0442\U0432\U043e \U043a\U043b\U0430\U043f\U0430\U043d\U043e\U0432.";
//                                                                           correct = 0;
//                                                                           id = 43870;
//                                                                       },
//                                                                       {
//                                                                           content = "\U0412\U0435\U0441 \U043c\U0430\U0448\U0438\U043d\U044b.";
//                                                                           correct = 0;
//                                                                           id = 43871;
//                                                                       },
//                                                                       {
//                                                                           content = "\U0413\U043e\U0434 \U0432\U044b\U043f\U0443\U0441\U043a\U0430.";
//                                                                           correct = 0;
//                                                                           id = 43872;
//                                                                       }
//                                                                       );
//                                        content = "\U0427\U0442\U043e \U043e\U0431\U043e\U0437\U043d\U0430\U0447\U0430\U0435\U0442 \U043d\U0430 \U043c\U0430\U0448\U0438\U043d\U0435 \"V12, V8, V6?";
//                                        "image_url" = "<null>";
//                                    };
//                                    "room_answers" =                 (
//                                                                      {
//                                                                          id = 1083;
//                                                                          "is_correct" = 1;
//                                                                          "player_id" = 64;
//                                                                          time = 3;
//                                                                      },
//                                                                      {
//                                                                          id = 1082;
//                                                                          "is_correct" = 1;
//                                                                          "player_id" = 7;
//                                                                          time = 4;
//                                                                      }
//                                                                      );
//                                };
//                            },
//                            {
//                                "room_question" =             {
//                                    id = 969;
//                                    question =                 {
//                                        answers =                     (
//                                                                       {
//                                                                           content = "\U0414\U0438\U0434\U0430\U0441\U043a\U0430\U043b";
//                                                                           correct = 1;
//                                                                           id = 18801;
//                                                                       },
//                                                                       {
//                                                                           content = "\U0425\U043e\U0440\U0435\U0433";
//                                                                           correct = 0;
//                                                                           id = 18802;
//                                                                       },
//                                                                       {
//                                                                           content = "\U0410\U0440\U0445\U043e\U043d\U0442";
//                                                                           correct = 0;
//                                                                           id = 18803;
//                                                                       },
//                                                                       {
//                                                                           content = "\U0410\U043a\U0441\U0430\U043a\U0430\U043b";
//                                                                           correct = 0;
//                                                                           id = 18804;
//                                                                       }
//                                                                       );
//                                        content = "\U041f\U0440\U043e\U0442\U043e\U043a\U043e\U043b \U0441\U043e\U0441\U0442\U044f\U0437\U0430\U043d\U0438\U0439 \U0442\U0435\U0430\U0442\U0440\U0430\U043b\U044c\U043d\U044b\U0445 \U0445\U043e\U0440\U043e\U0432 \U0432 \U0414\U0440\U0435\U0432\U043d\U0435\U0439 \U0413\U0440\U0435\U0446\U0438\U0438?";
//                                        "image_url" = "<null>";
//                                    };
//                                    "room_answers" =                 (
//                                                                      {
//                                                                          id = 1085;
//                                                                          "is_correct" = 1;
//                                                                          "player_id" = 64;
//                                                                          time = 2;
//                                                                      },
//                                                                      {
//                                                                          id = 1084;
//                                                                          "is_correct" = 0;
//                                                                          "player_id" = 7;
//                                                                          time = 3;
//                                                                      }
//                                                                      );
//                                };
//                            },
//                            {
//                                "room_question" =             {
//                                    id = 968;
//                                    question =                 {
//                                        answers =                     (
//                                                                       {
//                                                                           content = "\U0421\U0435\U0440\U0430\U0444\U0438\U043c \U0421\U0430\U0440\U043e\U0432\U0441\U043a\U0438\U0439";
//                                                                           correct = 1;
//                                                                           id = 18865;
//                                                                       },
//                                                                       {
//                                                                           content = "\U0410\U0440\U043a\U0430\U0434\U0438\U0439 \U041d\U043e\U0432\U043e\U0442\U043e\U0440\U0436\U0441\U043a\U0438\U0439";
//                                                                           correct = 0;
//                                                                           id = 18866;
//                                                                       },
//                                                                       {
//                                                                           content = "\U0413\U0435\U043e\U0440\U0433\U0438\U0439 \U0423\U0433\U0440\U0438\U043d";
//                                                                           correct = 0;
//                                                                           id = 18867;
//                                                                       },
//                                                                       {
//                                                                           content = "\U0415\U0444\U0440\U0435\U043c \U041f\U0435\U0447\U0435\U0440\U0441\U043a\U0438\U0439";
//                                                                           correct = 0;
//                                                                           id = 18868;
//                                                                       }
//                                                                       );
//                                        content = "\U041a\U0430\U043a\U043e\U0439 \U0441\U0432\U044f\U0442\U043e\U0439 \U043d\U0430 \U0431\U043e\U043b\U044c\U0448\U0438\U043d\U0441\U0442\U0432\U0435 \U0438\U043a\U043e\U043d \U0438\U0437\U043e\U0431\U0440\U0430\U0436\U0435\U043d \U043c\U043e\U043b\U044f\U0449\U0438\U043c\U0441\U044f \U043d\U0430 \U043a\U0430\U043c\U043d\U0435?";
//                                        "image_url" = "<null>";
//                                    };
//                                    "room_answers" =                 (
//                                                                      {
//                                                                          id = 1087;
//                                                                          "is_correct" = 1;
//                                                                          "player_id" = 64;
//                                                                          time = 3;
//                                                                      },
//                                                                      {
//                                                                          id = 1086;
//                                                                          "is_correct" = 0;
//                                                                          "player_id" = 7;
//                                                                          time = 2;
//                                                                      }
//                                                                      );
//                                };
//                            },
//                            {
//                                "room_question" =             {
//                                    id = 967;
//                                    question =                 {
//                                        answers =                     (
//                                                                       {
//                                                                           content = "\U041f\U0440\U0438 \U0440\U043e\U0436\U0434\U0435\U043d\U0438\U0438";
//                                                                           correct = 1;
//                                                                           id = 18845;
//                                                                       },
//                                                                       {
//                                                                           content = "\U041f\U0440\U0438 \U043a\U0440\U0435\U0449\U0435\U043d\U0438\U0438";
//                                                                           correct = 0;
//                                                                           id = 18846;
//                                                                       },
//                                                                       {
//                                                                           content = "\U041f\U0440\U0438 \U043f\U043e\U0441\U0432\U044f\U0449\U0435\U043d\U0438\U0438 \U0432 \U0438\U043a\U043e\U043d\U043e\U043f\U0438\U0441\U0446\U044b";
//                                                                           correct = 0;
//                                                                           id = 18847;
//                                                                       },
//                                                                       {
//                                                                           content = "\U041f\U0440\U0438 \U043f\U043e\U0441\U0442\U0440\U0438\U0433\U0435 \U0432 \U043c\U043e\U043d\U0430\U0448\U0435\U0441\U0442\U0432\U043e";
//                                                                           correct = 0;
//                                                                           id = 18848;
//                                                                       }
//                                                                       );
//                                        content = "\U041a\U043e\U0433\U0434\U0430 \U0420\U0443\U0431\U043b\U0435\U0432 \U043f\U043e\U043b\U0443\U0447\U0438\U043b \U0438\U043c\U044f \U0410\U043d\U0434\U0440\U0435\U0439?";
//                                        "image_url" = "<null>";
//                                    };
//                                    "room_answers" =                 (
//                                                                      {
//                                                                          id = 1089;
//                                                                          "is_correct" = 1;
//                                                                          "player_id" = 64;
//                                                                          time = 3;
//                                                                      },
//                                                                      {
//                                                                          id = 1088;
//                                                                          "is_correct" = 0;
//                                                                          "player_id" = 7;
//                                                                          time = 3;
//                                                                      }
//                                                                      );
//                                };
//                            }
//                            );
//}
//


@end
