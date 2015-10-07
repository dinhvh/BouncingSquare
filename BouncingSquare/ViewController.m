//
//  ViewController.m
//  BouncingSquare
//

#import "ViewController.h"

@interface ViewController ()

@end

enum {
    POSITION_TOP,
    POSITION_BOTTOM,
};

@implementation ViewController {
    UIPanGestureRecognizer * _gestureRecognizer;
    UIView * _square;
    int _initialPosition;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _initialPosition = POSITION_TOP;
    
    _square = [[UIView alloc] initWithFrame:[self _stickyPosition]];
    [_square setUserInteractionEnabled:NO];
    [_square setAutoresizesSubviews:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [_square setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:1.0]];
    [[self view] addSubview:_square];
    
    _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGestureRecognized:)];
    [[self view] addGestureRecognizer:_gestureRecognizer];
}

- (CGRect) _stickyPosition
{
    CGRect rect = CGRectMake(0, 0, 200, 200);
    if (_initialPosition == POSITION_TOP) {
        rect.origin.x = ([[self view] bounds].size.width - 200) / 2;
        rect.origin.y = [[self view] bounds].size.height / 2 - 250;
    }
    else {
        rect.origin.x = ([[self view] bounds].size.width - 200) / 2;
        rect.origin.y = [[self view] bounds].size.height / 2 + 50;
    }
    return rect;
}

- (void) _panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:[self view]];
    CGRect frame = [_square frame];
    frame.origin.x += translation.x;
    frame.origin.y += translation.y;
    [_square setFrame:frame];
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        CGPoint velocityVector = [recognizer velocityInView:[self view]];
        CGFloat velocity = sqrtf(velocityVector.x * velocityVector.x + velocityVector.y * velocityVector.y);
        NSLog(@"animate with velocity %g", velocity);
        
        CGRect intendedPosition = [_square frame];
        CGPoint distanceVector = velocityVector;
        distanceVector.x /= 10;
        distanceVector.y /= 10;
        intendedPosition.origin.x += distanceVector.x;
        intendedPosition.origin.y += distanceVector.y;
        
        if (_initialPosition == POSITION_TOP) {
            if (intendedPosition.origin.y > [[self view] bounds].size.height / 2) {
                _initialPosition = POSITION_BOTTOM;
            }
        }
        else {
            if (intendedPosition.origin.y < [[self view] bounds].size.height / 2 - 200) {
                _initialPosition = POSITION_TOP;
            }
        }
        
        if (velocity > 500) {
            NSLog(@"get back to initial position with signifiant speed");
            CGFloat distance = sqrtf(distanceVector.x * distanceVector.x + distanceVector.y * distanceVector.y);
            CGFloat time = distance / velocity;
            NSLog(@"velocity: %g, dist: %g, time: %g", velocity, distance, time);
            [UIView animateWithDuration:time
                                  delay:0.
                 usingSpringWithDamping:1.0
                  initialSpringVelocity:1 / time
                                options:0
                             animations:^{
                                 CGRect frame = [_square frame];
                                 frame.origin.x += distanceVector.x;
                                 frame.origin.y += distanceVector.y;
                                 [_square setFrame:frame];
                             } completion:^(BOOL finished){
                                 __weak ViewController * weakSelf = self;
                                 [UIView animateWithDuration:0.5
                                                       delay:0.
                                      usingSpringWithDamping:0.7
                                       initialSpringVelocity:2
                                                     options:0
                                                  animations:^{
                                                      ViewController * strongSelf = weakSelf;
                                                      [_square setFrame:[strongSelf _stickyPosition]];
                                                  } completion:^(BOOL finished){}];
                             }];
        }
        else {
            NSLog(@"get back to initial position without signifiant initial speed");
            __weak ViewController * weakSelf = self;
            [UIView animateWithDuration:0.5
                                  delay:0.
                 usingSpringWithDamping:1.
                  initialSpringVelocity:2
                                options:0
                             animations:^{
                                 ViewController * strongSelf = weakSelf;
                                 [_square setFrame:[strongSelf _stickyPosition]];
                             } completion:^(BOOL finished){}];
        }
    }
}

@end
