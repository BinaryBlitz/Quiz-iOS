#import "QZBUserWorker.h"

#import "QZBAnotherUser.h"
#import "QZBServerManager.h"
#import "QZBCurrentUser.h"
#import "MagicalRecord/MagicalRecord.h"

@implementation QZBUserWorker

+ (NSDictionary *)dictForUser:(id <QZBUserProtocol>)user {
  NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];

  NSString *userID = nil;
  if ([user.userID isKindOfClass:[NSString class]]) {
    userID = (NSString *) user.userID;
  } else {
    userID = user.userID.stringValue;
  }

  [tmpDict setObject:userID forKey:@"id"];
  [tmpDict setObject:user.name forKey:@"username"];

  if (user.imageURL) {
    NSString *urlAsString = [user.imageURL.absoluteString stringByReplacingOccurrencesOfString:QZBServerBaseUrl
                                                                                    withString:@""];
    [tmpDict setObject:urlAsString forKey:@"avatar_thumb_url"];
  }

  if (user.imageURLBig) {
    NSString *urlAsString = [user.imageURLBig.absoluteString stringByReplacingOccurrencesOfString:QZBServerBaseUrl
                                                                                       withString:@""];
    [tmpDict setObject:urlAsString forKey:@"avatar_url"];
  }

  return [NSDictionary dictionaryWithDictionary:tmpDict];
}


@end
