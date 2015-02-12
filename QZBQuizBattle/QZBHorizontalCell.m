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

@interface QZBHorizontalCell ()

@property (strong, nonatomic) NSArray *somethingArray;

@end

@implementation QZBHorizontalCell

- (void)awakeFromNib {
    // Initialization code

    CGRect screenRect = [[UIScreen mainScreen] bounds];

    CGRect rect = CGRectMake(0, 0, 100, screenRect.size.width);

    self.horizontalTabelView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.horizontalTabelView.rowHeight = 100;

    self.horizontalTabelView.showsVerticalScrollIndicator = NO;
    self.horizontalTabelView.showsHorizontalScrollIndicator = NO;
    self.horizontalTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.horizontalTabelView.allowsSelection = NO;

    CGAffineTransform transform = CGAffineTransformMakeRotation(-1.5707963);
    self.horizontalTabelView.transform = transform;

    CGRect contentRect = CGRectMake(0, 0, screenRect.size.width, 126);

    self.horizontalTabelView.frame = contentRect;

    NSLog(@"width %f  heigth %f", self.bounds.size.width, self.bounds.size.height);

    // self.horizontalTabelView.rowHeight = 100;

    [self addSubview:self.horizontalTabelView];

    self.horizontalTabelView.delegate = self;
    self.horizontalTabelView.dataSource = self;

    [self.horizontalTabelView registerClass:[QZBSomethingInHorizontalTabelViewCell class]
                     forCellReuseIdentifier:@"somethingInHorizontalCell"];

    [self.horizontalTabelView registerClass:[QZBLastElementInHorizontalTCCell class]
                     forCellReuseIdentifier:@"lastHorizontalElement"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.somethingArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"somethingInHorizontalCell";
    static NSString *lastIdentifier = @"lastHorizontalElement";

    UITableViewCell *cell;

    if (indexPath.row < [self.somethingArray count] - 1) {
        QZBSomethingInHorizontalTabelViewCell *playerCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        [self setCell:playerCell withObject:self.somethingArray[indexPath.row]];
        cell = playerCell;
    } else {
        QZBLastElementInHorizontalTCCell *lastCell = [tableView dequeueReusableCellWithIdentifier:lastIdentifier];

        cell = lastCell;
    }

    return cell;
}

- (void)setCell:(QZBSomethingInHorizontalTabelViewCell *)cell withObject:(id)object {
    if ([object isKindOfClass:[QZBAchievement class]]) {
        QZBAchievement *achiv = (QZBAchievement *)object;

        [cell setName:achiv.name picture:achiv.image];

    } else {  // redo
        [cell setName:@"drumih" picURLAsString:@"https://pp.vk.me/c320926/v320926839/c6aa/E7Ai5pmMgn4.jpg"];
    }
}

- (void)setSomethingArray:(NSArray *)somethingArray {
    _somethingArray = somethingArray;
   // [self.horizontalTabelView reloadData];
}

@end