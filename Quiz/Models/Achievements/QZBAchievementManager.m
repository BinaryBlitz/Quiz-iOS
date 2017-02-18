#import "QZBAchievementManager.h"
#import "QZBAchievement.h"
#import "QZBServerManager.h"

@interface QZBAchievementManager ()

@property (strong, nonatomic) NSArray *achievements;

@end

@implementation QZBAchievementManager

+ (instancetype)sharedInstance {
  static QZBAchievementManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[QZBAchievementManager alloc] init];
    // Do any other initialisation stuff here
  });
  return sharedInstance;
}

- (void)updateAchievements {
  [[QZBServerManager sharedManager] GETachievementsForUserID:@(0)
                                                   onSuccess:^(NSArray *achievements) {
                                                     for (QZBAchievement *achiev in achievements) {
                                                       [achiev makeAchievementUnGetted];
                                                     }

                                                     self.achievements = achievements;

                                                   }
                                                   onFailure:^(NSError *error, NSInteger statusCode) {

                                                   }];
}

- (NSArray *)mergeAchievemtsWithGetted:(NSArray *)achievements {

  if (!self.achievements || self.achievements.count == 0) {
    [self updateAchievements];

    return achievements;
  } else {

    for (QZBAchievement *ach in self.achievements) {
      [ach makeAchievementUnGetted];
    }

    for (QZBAchievement *achiev in achievements) {
      // [achiev makeAchievementUnGetted];


      NSUInteger index = [self.achievements indexOfObject:achiev];

      QZBAchievement *a = self.achievements[index];
      [a makeAchievementGetted];

    }
    return self.achievements;
  }

}

@end
