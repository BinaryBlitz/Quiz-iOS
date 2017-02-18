#import "QZBUserInRoomCell.h"
#import "QZBUserWithTopic.h"
#import "QZBGameTopic.h"
#import <DFImageView.h>
#import "UIColor+QZBProjectColors.h"

@implementation QZBUserInRoomCell

-(void)awakeFromNib{
    
    
    self.isReadyBackView.layer.borderWidth = 2.0;
    self.isReadyBackView.layer.borderColor = [UIColor goldColor].CGColor;
}

- (void)configureCellWithUserWithTopic:(QZBUserWithTopic *)userWithTopic {
    
    self.usernameLabel.text = userWithTopic.user.name;
    self.topicNameLabel.text = userWithTopic.topic.name;
    //self.numberOfUserInRoomLabel.text = @"";
    if([userWithTopic.user respondsToSelector:@selector(isFriend)]){
        
        if(userWithTopic.user.isFriend){
            self.usernameLabel.textColor = [UIColor ultralightGreenColor];
        } else {
            self.usernameLabel.textColor = [UIColor whiteColor];
        }
    } else {
        self.usernameLabel.textColor = [UIColor whiteColor];
    }

    
    
    self.isReadyActivityIndicator.hidden = YES;
    
    NSString *readyText = @"";
    if(userWithTopic.isReady){
        readyText = @"ГОТОВ";
    } else {
        readyText = @"НЕ ГОТОВ";
    }
    
    self.isReadyLabel.text = readyText;
    
//    UIView *isReadyBackView = self.isReadyLabel.superview;
    
//    isReadyBackView.layer.borderWidth = 2.0;
//    isReadyBackView.layer.borderColor = [UIColor goldColor].CGColor;
    
//    if(userWithTopic.user.imageURL){
//        self.userPicImageView.allowsAnimations = YES;
//        
//        [self.userPicImageView prepareForReuse];
//        
//        
//        [self.userPicImageView setImageWithResource:userWithTopic.user.imageURL];
//        
//    }else{
//        [self.userPicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
//    }
    
}



@end
