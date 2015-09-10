//
//  QZBComment.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 07/09/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@interface QZBComment : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, assign) BOOL isSended;

@property (nonatomic, strong) id <QZBUserProtocol> owner;
//@property (nonatomic, strong) UIImage *attachment;

@end
