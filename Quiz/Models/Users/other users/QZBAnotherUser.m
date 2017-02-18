#import "QZBAnotherUser.h"
#import "QZBServerManager.h"

@implementation QZBAnotherUser

//@synthesize name = _name;
//@synthesize userID = _userID;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self) {

    if (![dict[@"username"] isEqual:[NSNull null]] && dict[@"username"]) {
      self.name = dict[@"username"];
    } else {
      self.name = @"";
    }

    // self.name = dict[@"name"];
    self.userID = @([dict[@"id"] integerValue]);

    self.userStatistics = [[QZBUserStatistic alloc] initWithDict:dict];

    NSString *avaURL = dict[@"avatar_thumb_url"];

    if (![avaURL isEqual:[NSNull null]] && avaURL) {

      if ([avaURL hasPrefix:QZBServerBaseUrl]) {
        self.imageURL = [NSURL URLWithString:avaURL];
      } else {

        NSString *urlStr = [QZBServerBaseUrl stringByAppendingString:avaURL];

        self.imageURL = [NSURL URLWithString:urlStr];
      }
    } else {
      self.imageURL = nil;
    }

    NSString *avaURLBig = dict[@"avatar_url"];

    if (![avaURLBig isEqual:[NSNull null]] && avaURLBig) {
      if ([avaURLBig hasPrefix:QZBServerBaseUrl]) {
        self.imageURLBig = [NSURL URLWithString:avaURLBig];
      } else {

        NSString *urlStr = [QZBServerBaseUrl stringByAppendingString:avaURLBig];
        self.imageURLBig = [NSURL URLWithString:urlStr];
      }
    } else {
      self.imageURLBig = nil;
    }

    if (![dict[@"viewed"] isEqual:[NSNull null]] && dict[@"viewed"]) {
      BOOL viewed = [dict[@"viewed"] boolValue];
      self.isViewed = viewed;
    } else {
      self.isViewed = YES;
    }

    if (dict[@"is_online"] && ![dict[@"is_online"] isEqual:[NSNull null]]) {
      self.isOnline = [dict[@"is_online"] boolValue];
    }

  }
  return self;
}

@end
