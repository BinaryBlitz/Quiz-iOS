#import <UIKit/UIKit.h>

@interface QZBAnswerButton : UIButton

@property(strong, nonatomic) UILabel *answerLabel;


- (void)addTriangleLeft;
- (void)addTriangleRight;
- (void)unshowTriangles;

-(void)addCircleRight;
-(void)addCircleLeft;
-(void)unshowCircles;

-(void)setAnswerText:(NSString *)answer;

@end
