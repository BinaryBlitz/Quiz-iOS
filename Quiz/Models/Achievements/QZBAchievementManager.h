#import <Foundation/Foundation.h>

@interface QZBAchievementManager : NSObject

@property(strong, nonatomic, readonly) NSArray *achievements;

+ (instancetype)sharedInstance;
- (void)updateAchievements;

-(NSArray *)mergeAchievemtsWithGetted:(NSArray *)achievements;

@end
