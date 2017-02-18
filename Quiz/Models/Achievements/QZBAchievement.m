#import "QZBAchievement.h"
#import "QZBServerManager.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

//dfiimage

#import <DFImageManager/DFImageManager.h>
#import <DFImageManager/DFImageRequestOptions.h>
#import <DFImageManager/DFURLImageFetcher.h>
#import <DFImageManager/DFImageRequest.h>
#import <DFImageManager/DFImageView.h>

@interface QZBAchievement ()

@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic)   NSString *name;
@property (strong, nonatomic) NSNumber *achievementID;
@property (copy, nonatomic)   NSString *achievementDescription;
@property (assign, nonatomic) BOOL isAchieved;
@property (strong, nonatomic) NSURL *imageURL;

@end

@implementation QZBAchievement

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imgName {
  self = [super init];
  if (self) {
    self.name = name;
    self.image = [UIImage imageNamed:imgName];
  }
  return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
  self = [super init];
  if (self) {

    self.name = dict[@"name"];
    self.achievementID = dict[@"id"];
    self.achievementDescription = dict[@"description"];
    self.isAchieved = [dict[@"achieved"] boolValue];


    if(![dict[@"icon_url"] isEqual:[NSNull null]] && dict[@"icon_url"] ){


      NSString *urlAsString = [QZBServerBaseUrl stringByAppendingString:dict[@"icon_url"]];

      self.imageURL = [NSURL URLWithString:urlAsString];


      DFMutableImageRequestOptions *options = [DFMutableImageRequestOptions new];

      options.userInfo = @{ DFURLRequestCachePolicyKey : @(NSURLRequestReturnCacheDataElseLoad ) };
      options.expirationAge = 60*60*24*10;
      options.priority = DFImageRequestPriorityLow;

      DFImageRequest *request = [DFImageRequest requestWithResource:self.imageURL targetSize:CGSizeZero contentMode:DFImageContentModeAspectFill options:options];

      [[DFImageManager sharedManager] imageTaskForRequest:request completion:nil];
    }

  }
  return self;
}

-(void)makeAchievementGetted{
  self.isAchieved = YES;
}

-(void)makeAchievementUnGetted{
  self.isAchieved = NO;
}

-(BOOL)isEqual:(id)object{
  if([object isKindOfClass:[QZBAchievement class]]){
    QZBAchievement *anotherAchievement = (QZBAchievement *)object;

    if([anotherAchievement.achievementID isEqualToNumber:self.achievementID]){
      return YES;
    }
  }
  return NO;
}



@end
