//
//  QZBStoreVCBase.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 27/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBStoreVCBase.h"

@interface QZBStoreVCBase()

@property (strong, nonatomic) NSNumberFormatter *priceFormatter;

@end

@implementation QZBStoreVCBase

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Востановить"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(restoreTapped:)];
}

- (void)restoreTapped:(id)sender{
    [NSException raise:@"not exist" format:nil];
}





@end
