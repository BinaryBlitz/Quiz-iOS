#import "QZBUserStatistic.h"

@interface QZBUserStatistic ()

@property (strong, nonatomic) NSNumber *losses;
@property (strong, nonatomic) NSNumber *wins;

@property (strong, nonatomic) NSNumber *totalDraws;
@property (strong, nonatomic) NSNumber *totaLosses;
@property (strong, nonatomic) NSNumber *totalWins;

@end

@implementation QZBUserStatistic

- (instancetype)initWithDict:(NSDictionary *)dict {
  self = [super init];
  if (self) {

    NSDictionary *scoreDict = dict[@"score"];
    NSDictionary *totalScoreDict = dict[@"total_score"];

    if (![scoreDict[@"losses"] isEqual:[NSNull null]]) {
      self.losses = scoreDict[@"losses"];
    } else {
      self.losses = nil;
    }

    if (![scoreDict[@"wins"] isEqual:[NSNull null]]) {
      self.wins = scoreDict[@"wins"];
    } else {
      self.wins = nil;
    }

    if (![totalScoreDict[@"draws"] isEqual:[NSNull null]]) {
      self.totalDraws = totalScoreDict[@"draws"];
    } else {
      self.totalDraws = nil;
    }

    if (![totalScoreDict[@"losses"] isEqual:[NSNull null]]) {
      self.totaLosses = totalScoreDict[@"losses"];
    } else {
      self.totaLosses = nil;
    }

    if (![totalScoreDict[@"wins"] isEqual:[NSNull null]]) {
      self.totalWins = totalScoreDict[@"wins"];
    } else {
      self.totalWins = nil;
    }

  }
  return self;
}

@end
