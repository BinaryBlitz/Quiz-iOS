//
//  QZBAnswerButton.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 21/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBAnswerButton : UIButton

- (void)addTriangleLeft;
- (void)addTriangleRight;
- (void)unshowTriangles;

-(void)addCircleRight;
-(void)addCircleLeft;
-(void)unshowCircles;

@end
