//
//  QZBFriendsHorizontalCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 22/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBHorizontalCell.h"
#import "QZBSomethingInHorizontalTabelViewCell.h"
#import "QZBLastElementInHorizontalTCCell.h"
#import "QZBAchievement.h"
#import "QZBAnotherUser.h"
#import "UITableViewCell+QZBCellCategory.h"
#import <CocoaLumberjack.h>

@interface QZBHorizontalCell ()

@property (strong, nonatomic) NSArray *somethingArray;

@end

@implementation QZBHorizontalCell

- (void)awakeFromNib {
    // Initialization code

    CGRect screenRect = [[UIScreen mainScreen] bounds];

    CGRect rect = CGRectMake(0, 0, 100, screenRect.size.width);
    
    self.horizontalTabelView.backgroundColor = [UIColor clearColor];
    self.horizontalTabelView.backgroundView.backgroundColor = [UIColor clearColor];

    self.horizontalTabelView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.horizontalTabelView.rowHeight = 100;

    self.horizontalTabelView.showsVerticalScrollIndicator = NO;
    self.horizontalTabelView.showsHorizontalScrollIndicator = NO;
    self.horizontalTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.horizontalTabelView.allowsSelection = YES;
   // self.horizontalTabelView.

    CGAffineTransform transform = CGAffineTransformMakeRotation(-1.5707963);
    self.horizontalTabelView.transform = transform;

    CGRect contentRect = CGRectMake(0, 0, screenRect.size.width, 126);

    self.horizontalTabelView.frame = contentRect;


    [self addSubview:self.horizontalTabelView];
    self.horizontalTabelView.backgroundColor = [UIColor clearColor];

    self.horizontalTabelView.delegate = self;
    self.horizontalTabelView.dataSource = self;

    [self.horizontalTabelView registerClass:[QZBSomethingInHorizontalTabelViewCell class]
                     forCellReuseIdentifier:@"somethingInHorizontalCell"];

    [self.horizontalTabelView registerClass:[QZBLastElementInHorizontalTCCell class]
                     forCellReuseIdentifier:@"lastHorizontalElement"];
    
    //[self addDropShadows];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.buttonTitle){
        return [self.somethingArray count]+1;
    } else{
        return [self.somethingArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"somethingInHorizontalCell";
    static NSString *lastIdentifier = @"lastHorizontalElement";

    UITableViewCell *cell;

    if (indexPath.row <= [self.somethingArray count] - 1) {
        QZBSomethingInHorizontalTabelViewCell *playerCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        [self setCell:playerCell withObject:self.somethingArray[indexPath.row]];
        cell = playerCell;
    } else {
        QZBLastElementInHorizontalTCCell *lastCell = [tableView dequeueReusableCellWithIdentifier:lastIdentifier];
        
        [lastCell setButtonTitle:self.buttonTitle];

        cell = lastCell;
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [cell setExclusiveTouch:YES];
    return cell;
}

- (void)setCell:(QZBSomethingInHorizontalTabelViewCell *)cell withObject:(id)object {
    if ([object isKindOfClass:[QZBAchievement class]]) {
        QZBAchievement *achiv = (QZBAchievement *)object;

        if(achiv.imageURL){
            [cell setName:achiv.name picURL:achiv.imageURL];
        }else{
            
            [cell setName:achiv.name picture:[UIImage imageNamed:@"achiv"]];
        }

    } else if([object isKindOfClass:[QZBAnotherUser class]]){
        
        QZBAnotherUser *user = (QZBAnotherUser *)object;
        
        if(user.imageURL){
            [cell setName:user.name picURL:user.imageURL];
        }else{
            [cell setName:user.name picture:[UIImage imageNamed:@"userpicStandart"]];
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
    
    UITableViewCell *cell= [tableView cellForRowAtIndexPath:indexPath];
    
    NSIndexPath *globalIP = [self getIndexPathCell:cell];
    
    NSDictionary *dict = @{@"indexInLocalTable":indexPath,@"indexInGlobalTable": globalIP};
    
    DDLogVerbose(@"row in global %ld , row in local %ld",(long)globalIP.row, (long)indexPath.row);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBUserPressSomethingInHorizontallTV"
                                                        object:dict];
    
    
}

- (NSIndexPath *)getIndexPathCell:(UIView *)view {
    if ([view isKindOfClass:[QZBHorizontalCell class]]) {
        // UITableView *tv = (UITableView *)view.superview;
        
        NSIndexPath *indexPath = [(UITableView *)view.superview.superview indexPathForCell:(UITableViewCell *)view];
        return indexPath;
        
    } else {
        return [self getIndexPathCell:view.superview];
    }
}


- (void)setSomethingArray:(NSArray *)somethingArray {
    _somethingArray = somethingArray;
    [self.horizontalTabelView reloadData];
}

@end
