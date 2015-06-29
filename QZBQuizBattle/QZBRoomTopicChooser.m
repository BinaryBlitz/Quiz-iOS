//
//  QZBRoomTopicChooser.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 17/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomTopicChooser.h"
#import "QZBRoomController.h"

#import "QZBSettingTopicProtocol.h"

@implementation QZBRoomTopicChooser

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *controllers = self.navigationController.viewControllers;
    id<QZBSettingTopicProtocol> destinationController = nil;

    for (UIViewController *c in controllers) {
        
        if([c respondsToSelector:@selector(setUserTopic:)]){
            destinationController = (id<QZBSettingTopicProtocol>)c;
            break;
        }
//        if ([c isKindOfClass:[QZBRoomController class]]) {
//            destinationController = (QZBRoomController *)c;
//            break;
//        }
    }

    QZBGameTopic *topic = self.topics[indexPath.row];
    [destinationController setUserTopic:topic];//setCurrentUserTopic:topic];

    UIViewController *destVC = (UIViewController *)destinationController;
    
    [self.navigationController popToViewController:destVC animated:YES];
}

@end
