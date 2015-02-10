//
//  QZBRatingVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRatingTVC.h"
#import "QZBRatingTVCell.h"
#import "UIImageView+AFNetworking.h"
#import "QZBRatingPageVC.h"

@interface QZBRatingTVC () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation QZBRatingTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.multipleTouchEnabled = NO;

    self.ratingTableView.delegate   = self;
    self.ratingTableView.dataSource = self;
    
  /*  UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(move:)];
    
    panGest.delegate = self;
    
    [self.ratingTableView addGestureRecognizer:panGest];*/
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"it shown %ld", self.tableType);
    if([self.parentViewController isKindOfClass:[QZBRatingPageVC class]]){
        
        QZBRatingPageVC *pageVC = (QZBRatingPageVC *)self.parentViewController;
        pageVC.expectedType = self.tableType;
       
        
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"hided %ld", self.tableType);
}
/*
-(void)move:(UIPanGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"move");
    }else if (sender.state == UIGestureRecognizerStateCancelled ||sender.state == UIGestureRecognizerStateEnded){
        NSLog(@"ended");
    }
    
}*/




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QZBRatingTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ratingCell"];
    cell.numberInRating.text = [NSString stringWithFormat:@"%ld", (indexPath.row + 1)];

    NSURL *url = [NSURL URLWithString:self.urlString];

    [cell.userpic setImageWithURL:url];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"touches began");
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    NSLog(@"mm");
    return NO;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
