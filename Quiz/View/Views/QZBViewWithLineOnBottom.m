#import "QZBViewWithLineOnBottom.h"

@implementation QZBViewWithLineOnBottom

-(void)drawRect:(CGRect)rect{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    
    //UIView *destView = self.buttonsBackgroundView.superview;
    
    CGPoint beginPoint = CGPointMake(0,rect.size.height-1);
    CGPoint endPoint = CGPointMake(rect.size.width,rect.size.height - 1);
    
    [path moveToPoint:beginPoint];
    [path addLineToPoint:endPoint];
    
    path.lineWidth = 1.0;
    
    [[UIColor lightGrayColor] setStroke];
    [path stroke];
}

@end
