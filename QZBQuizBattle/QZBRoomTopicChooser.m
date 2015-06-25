//
//  QZBRoomTopicChooser.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 17/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomTopicChooser.h"
#import "QZBRoomController.h"

@implementation QZBRoomTopicChooser

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *controllers = self.navigationController.viewControllers;
    QZBRoomController *destinationController = nil;

    for (UIViewController *c in controllers) {
        if ([c isKindOfClass:[QZBRoomController class]]) {
            destinationController = (QZBRoomController *)c;
            break;
        }
    }

    QZBGameTopic *topic = self.topics[indexPath.row];
    [destinationController setCurrentUserTopic:topic];

    [self.navigationController popToViewController:destinationController animated:YES];
}

@end
