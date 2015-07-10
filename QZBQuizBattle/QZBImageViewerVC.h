//
//  QZBImageViewerVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@interface QZBImageViewerVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *userPicImageView;

-(void)configureWithUser:(id<QZBUserProtocol>)user;

@end
