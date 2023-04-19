
#import "JFDragableView.h"
#import "../Drawzb.h"

@interface JFDragableView ()

@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) CGPoint didMovePoint;

@end

@implementation JFDragableView

#pragma mark 
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    CGPoint pt = [[touches anyObject] locationInView:self];
    _startLocation = pt;
    [[self superview] bringSubviewToFront:self];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    CGPoint pt = [[touches anyObject] locationInView:self];
    float dx = pt.x - _startLocation.x;
    float dy = pt.y - _startLocation.y;
    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    
    float halfx = CGRectGetMidX(self.bounds);
    newcenter.x = MAX(halfx, newcenter.x);
    newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
    
    float halfy = CGRectGetMidY(self.bounds);
    newcenter.y = MAX(halfy, newcenter.y);
    newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);
    
    CGFloat bottom = self.superview.height - newcenter.y - 0.5 * self.height;
    if (bottom < 0) {
        bottom = 0;
    }
    
    if (bottom > SCREEN_HEIGHT) {
        bottom = SCREEN_HEIGHT;
    }
    
    newcenter.y = self.superview.height - bottom - 0.5 * self.height;
    
    self.center = newcenter;
    
    self.didMovePoint = CGPointMake(self.left, self.superview.height - self.bottom);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.didMovePoint = CGPointMake(self.left, self.superview.height - self.bottom);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

@end
