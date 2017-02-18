#import "QZBUserWithTopic.h"
#import "QZBGameTopic.h"

@interface QZBUserWithTopic ()

@property (strong, nonatomic) id <QZBUserProtocol> user;
@property (strong, nonatomic) QZBGameTopic *topic;
//@property(strong, nonatomic) NSNumber *points;
//@property(assign, nonatomic, getter=isAdmin) BOOL admin;
//@property(assign, nonatomic, getter = isFinished) BOOL finished;

@end

@implementation QZBUserWithTopic

- (instancetype)initWithUser:(id <QZBUserProtocol>)user topic:(QZBGameTopic *)topic {
  self = [super init];
  if (self) {
    self.user = user;
    self.topic = topic;
    self.finished = YES;//redo
    self.points = @(0);

  }
  return self;
}

- (void)addReachedPoints:(NSNumber *)points {
  // self.points+=points;
  NSInteger currentPoints = [self.points integerValue];
  NSInteger newPoints = [points integerValue];
  currentPoints += newPoints;
  self.points = @(currentPoints);
}


//-(void)setPoints:(NSNumber *)points {
//    _points = points;
//}



@end
