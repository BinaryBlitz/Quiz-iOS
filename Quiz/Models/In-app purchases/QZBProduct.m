#import "QZBProduct.h"

@interface QZBProduct ()

@property (copy, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSNumber *topicID;
@property (assign, nonatomic) BOOL isPurchased;
@property (strong, nonatomic) NSDate *expiratesDate;
@property (assign, nonatomic) int dayCount;

@end

@implementation QZBProduct

- (instancetype)initWhithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self) {
//        "identifier": "booster-x3",
//        "topic_id": null,
//        "purchased": true

    self.identifier = dict[@"identifier"];
    self.topicID = dict[@"topic_id"];
    self.isPurchased = [dict[@"purchased"] boolValue];

    if (![dict[@"expires_at"] isEqual:[NSNull null]] && dict[@"expires_at"]) {

      NSString *dateAsString = dict[@"expires_at"];

      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

      [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
      [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
      [dateFormat setLocale:[NSLocale systemLocale]];

      self.expiratesDate = [dateFormat dateFromString:dateAsString];

      self.dayCount = [self daysRemainingOnSubscription];
    } else {
      self.dayCount = -1;
    }
  }
  return self;
}

- (int)daysRemainingOnSubscription {
  //1
  NSDate *expirationDate = self.expiratesDate;

  //2
  NSTimeInterval timeInt = [expirationDate timeIntervalSinceDate:[NSDate date]];

  //3
  int days = timeInt / 60 / 60 / 24;

  //4
  if (days > 0) {
    return days;
  } else {
    return 0;
  }
}


@end
