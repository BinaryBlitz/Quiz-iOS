//
//  QZBCreateRoomController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 29/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBCreateRoomController.h"

//cell identifiers

NSString *const QZBPlayerCountChooserCellIdentifier = @"playerCountChooserCell";
NSString *const QZBChooseTopicCellIdentifier = @"chooseTopicCellIdentifier";

@implementation QZBCreateRoomController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"Создание комнаты";
}

@end
