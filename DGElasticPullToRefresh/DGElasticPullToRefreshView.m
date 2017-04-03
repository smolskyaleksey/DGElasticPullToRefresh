//
//  DGElasticPullToRefreshView.m
//  DGElasticPullToRefreshExample
//
//  Created by Smolski, Aliaksei on 31.03.17.
//  Copyright © 2017 Danil Gontovnik. All rights reserved.
//

#import "DGElasticPullToRefreshView.h"
#import "DGElasticPullToRefreshConstants.h"
#import "UIView+DGElasticPullToRefreshExtensions.h"
#import "UIScrollView+DGElasticPullToRefreshExtensions.h"
#import "NSObject+DGElasticPullToRefreshExtensions.h"

typedef NS_ENUM (NSInteger,DGElasticPullToRefreshState) {
    DGElasticPullToRefreshStateStopped,
    DGElasticPullToRefreshStateDragging,
    DGElasticPullToRefreshStateAnimatingBounce,
    DGElasticPullToRefreshStateLoading,
    DGElasticPullToRefreshStateAnimatingToStopped,
};


@interface DGElasticPullToRefreshView()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (strong, nonatomic) UIView *l3ControlPointView;
@property (strong, nonatomic) UIView *l2ControlPointView;
@property (strong, nonatomic) UIView *l1ControlPointView;
@property (strong, nonatomic) UIView *cControlPointView;
@property (strong, nonatomic) UIView *r1ControlPointView;
@property (strong, nonatomic) UIView *r2ControlPointView;
@property (strong, nonatomic) UIView *r3ControlPointView;
@property (strong, nonatomic) UIView *bounceAnimationHelperView;

@property (nonatomic, assign) DGElasticPullToRefreshState state;
@property (nonatomic, assign) CGFloat originalContentInsetTop;
@end


@implementation DGElasticPullToRefreshView
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.observing = NO;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    if (self != nil) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink.paused = YES;
        self.shapeLayer = [CAShapeLayer new];
        self.shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
        self.shapeLayer.fillColor = [[UIColor blackColor] CGColor];
        self.shapeLayer.actions =  @{@"path":[NSNull null],
                                     @"position":[NSNull null],
                                     @"bounds":[NSNull null]};
        [self.layer addSublayer:self.shapeLayer];
        
        _bounceAnimationHelperView = [UIView new];
        _cControlPointView = [UIView new];
        _l1ControlPointView = [UIView new];
        _l2ControlPointView = [UIView new];
        _l3ControlPointView = [UIView new];
        _r1ControlPointView = [UIView new];
        _r2ControlPointView = [UIView new];
        _r3ControlPointView = [UIView new];
        
        [self addSubview:_bounceAnimationHelperView];
        [self addSubview:_cControlPointView];
        [self addSubview:_l1ControlPointView];
        [self addSubview:_l2ControlPointView];
        [self addSubview:_l3ControlPointView];
        [self addSubview:_r1ControlPointView];
        [self addSubview:_r2ControlPointView];
        [self addSubview:_r3ControlPointView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        self.state = DGElasticPullToRefreshStateStopped;
        self.originalContentInsetTop = 0;
        self.fillColor = [UIColor clearColor];
    }
    return self;
}

- (void)applicationWillEnterForeground {
    if (self.state == DGElasticPullToRefreshStateLoading) {
        [self layoutSubviews];
    }
}

- (void)displayLinkTick {
    CGFloat width = self.bounds.size.width;
    CGFloat height = 0.0;
    if (self.state == DGElasticPullToRefreshStateAnimatingBounce) {
        UIScrollView *scroll = [self scrollView];
        if (scroll == nil) {
            return;
        }
        UIEdgeInsets contentInset = scroll.contentInset;
        contentInset.top = [self.bounceAnimationHelperView dg_center:[self isAnimating]].y;
        scroll.contentInset = contentInset;
        CGPoint contentOffset = scroll.contentOffset;
        contentOffset.y = -scroll.contentInset.top;
        scroll.contentOffset = contentOffset;
        height = scroll.contentInset.top - self.originalContentInsetTop;
        
        self.frame = CGRectMake(0,  -height - 1.0, width, height);
    } else if (self.state == DGElasticPullToRefreshStateAnimatingToStopped) {
        height = [self actualContentOffsetY];
    }
    
    self.shapeLayer.frame = CGRectMake(0, 0, width, height);
    self.shapeLayer.path = [self currentPath];
    [self layoutLoadingView];
}

- (void)setState:(DGElasticPullToRefreshState)newState {
    DGElasticPullToRefreshState previousValue = _state;
    _state = newState;
    if (previousValue == DGElasticPullToRefreshStateDragging &&
        newState == DGElasticPullToRefreshStateAnimatingBounce) {
        [self.loadingView startAnimating];
        [self animateBounce];
    } else if (newState == DGElasticPullToRefreshStateLoading &&
               self.actionHandler != nil) {
        self.actionHandler();
    } else if (newState == DGElasticPullToRefreshStateAnimatingToStopped) {
        __weak typeof(self) weakSelf = self;
        [self resetScrollViewContentInset:YES animated:YES completion:^{
            weakSelf.state = DGElasticPullToRefreshStateStopped;
        }];
    } else if (newState == DGElasticPullToRefreshStateStopped) {
        [self.loadingView stopLoading];
    }
}

- (void)setOriginalContentInsetTop:(CGFloat)originalContentInsetTop {
    _originalContentInsetTop = originalContentInsetTop;
    [self layoutSubviews];
}

- (void)setLoadingView:(DGElasticPullToRefreshLoadingView *)loadingView {
    [_loadingView removeFromSuperview];
    _loadingView = loadingView;
    [self addSubview:loadingView];
}

- (void)setObserving:(BOOL)observing {
    _observing = observing;
    UIScrollView *scrollView = [self scrollView];
    if (scrollView == nil) {
        return;
    }

    if (observing) {
        [scrollView dg_addObserver:self forKeyPath:kContentOffset ];
        [scrollView dg_addObserver:self forKeyPath:kContentInset ];
        [scrollView dg_addObserver:self forKeyPath:kFrame ];
        [scrollView dg_addObserver:self forKeyPath:kPanGestureRecognizerState ];
    } else {
        [scrollView dg_removeObserver:self forKeyPath:kContentOffset];
        [scrollView dg_removeObserver:self forKeyPath:kContentInset];
        [scrollView dg_removeObserver:self forKeyPath:kFrame];
        [scrollView dg_removeObserver:self forKeyPath:kPanGestureRecognizerState];
    }
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    self.shapeLayer.fillColor = [fillColor CGColor];
}

#pragma mark -
/**
 Has to be called when the receiver is no longer required. Otherwise the main loop holds a reference to the receiver which in turn will prevent the receiver from being deallocated.
 */
- (void)disassociateDisplayLink {
    [self.displayLink invalidate];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (keyPath == kContentOffset) {
        id newContentOffset = change[NSKeyValueChangeNewKey];
        UIScrollView *scrollView = [self scrollView];
        
        CGFloat newContentOffsetY = [newContentOffset CGPointValue].y;
        
        if ((self.state == DGElasticPullToRefreshStateLoading || self.state == DGElasticPullToRefreshStateAnimatingToStopped) &&
            newContentOffsetY < -scrollView.contentInset.top) {
            CGPoint offset = scrollView.contentOffset;
            offset.y =  -scrollView.contentInset.top;
            scrollView.contentOffset = offset;
        } else {
            [self scrollViewDidChangeContentOffset:scrollView.dragging];
        }
        [self layoutSubviews];
        
    }else if(keyPath == kContentInset) {
        id newContentInset = change[NSKeyValueChangeNewKey];
        CGFloat newContentInsetTop = [newContentInset UIEdgeInsetsValue].top;
        self.originalContentInsetTop = newContentInsetTop;
    } else if(keyPath == kFrame) {
        [self layoutSubviews];
    } else if(keyPath == kPanGestureRecognizerState) {
        UIGestureRecognizerState gestureState = [self scrollView].panGestureRecognizer.state;
        if (gestureState == UIGestureRecognizerStateEnded ||
            gestureState == UIGestureRecognizerStateCancelled ||
            gestureState == UIGestureRecognizerStateFailed ) {
            [self scrollViewDidChangeContentOffset:NO];
        }
    }
}

- (UIScrollView *)scrollView {
    return (UIScrollView *)self.superview;
}

- (void)stopLoading {
    // Prevent stop close animation
    if (self.state == DGElasticPullToRefreshStateAnimatingToStopped) {
        return;
    }
    self.state = DGElasticPullToRefreshStateAnimatingToStopped;
}

#pragma mark - Private
- (BOOL)isAnimating {
    return self.state == DGElasticPullToRefreshStateAnimatingToStopped || self.state == DGElasticPullToRefreshStateAnimatingBounce;
}

- (CGFloat)actualContentOffsetY {
    UIScrollView *scroll = [self scrollView];
    if (scroll == nil) {
        return 0.0;
    }
    return MAX(-scroll.contentInset.top - scroll.contentOffset.y, 0);
}

- (CGFloat)currentHeight {
    UIScrollView *scroll = [self scrollView];
    if (scroll == nil) {
        return 0.0;
    }
    return MAX(-self.originalContentInsetTop - scroll.contentOffset.y, 0);
}

- (CGFloat)currentWaveHeight {
    return MIN(self.bounds.size.height/3.0 * 1.6, kWaveMaxHeight);
}

- (CGPathRef)currentPath {
    CGFloat width = [self scrollView].bounds.size.width;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    BOOL animating = [self isAnimating];
    
    [bezierPath moveToPoint:CGPointMake(0, 0)];
    
    [bezierPath addLineToPoint:CGPointMake(0, [self.l3ControlPointView dg_center:animating].y)];
    
    [bezierPath addCurveToPoint:[self.l1ControlPointView dg_center:animating]
                  controlPoint1:[self.l3ControlPointView dg_center:animating]
                  controlPoint2:[self.l2ControlPointView dg_center:animating]];
    
    [bezierPath addCurveToPoint:[self.r1ControlPointView dg_center:animating]
                  controlPoint1:[self.cControlPointView dg_center:animating]
                  controlPoint2:[self.r1ControlPointView dg_center:animating]];
    
    [bezierPath addCurveToPoint:[self.r3ControlPointView dg_center:animating]
                  controlPoint1:[self.r1ControlPointView dg_center:animating]
                  controlPoint2:[self.r2ControlPointView dg_center:animating]];
    
    [bezierPath addLineToPoint:CGPointMake(width, 0)];
    
    [bezierPath closePath];
    
    return bezierPath.CGPath;
}

- (void)scrollViewDidChangeContentOffset:(BOOL)dragging {
   CGFloat offsetY = [self actualContentOffsetY];
    
    if (self.state == DGElasticPullToRefreshStateStopped && dragging) {
        self.state = DGElasticPullToRefreshStateDragging;
    } else if (self.state == DGElasticPullToRefreshStateDragging && !dragging) {
        if (offsetY >= kMinOffsetToPull) {
            self.state = DGElasticPullToRefreshStateAnimatingBounce;
        } else {
            self.state = DGElasticPullToRefreshStateStopped;
        }
    } else if (self.state == DGElasticPullToRefreshStateDragging ||
               self.state == DGElasticPullToRefreshStateStopped) {
        CGFloat pullProgress = offsetY/kMinOffsetToPull;
        [self.loadingView setPullProgress:pullProgress];
    }
}

- (void)resetScrollViewContentInset:(BOOL)shouldAddObserverWhenFinished animated:(BOOL)animated
                         completion:(void (^)())completion {
    UIScrollView *scrollView = [self scrollView];
    if (scrollView == nil) {
        return;
    }
    
    UIEdgeInsets contentInset = scrollView.contentInset;
    contentInset.top = self.originalContentInsetTop;
    
    if (self.state == DGElasticPullToRefreshStateAnimatingBounce) {
        contentInset.top += [self currentHeight];
    } else if (self.state == DGElasticPullToRefreshStateLoading) {
        contentInset.top += kLoadingContentInset;
    }
    
    [scrollView dg_removeObserver:self forKeyPath:kContentInset];
    
    void(^animationBlock)() = ^(){
        scrollView.contentInset = contentInset;
    };
    
    void(^completionBlock)() = ^(){
        if (shouldAddObserverWhenFinished && self.observing) {
            [scrollView dg_addObserver:self forKeyPath:kContentInset];
        }
        if (completion != nil) {
            completion();
        }
    };
    
    if (animated) {
        [self startDisplayLink];
        [UIView animateWithDuration:0.4 animations:animationBlock completion:^(BOOL finished) {
            [self stopDisplayLink];
            completionBlock();
        }];
    } else {
        animationBlock();
        completionBlock();
    }
}

- (void)startDisplayLink{
    self.displayLink.paused = NO;
}

- (void)stopDisplayLink {
    self.displayLink.paused = YES;
}

- (void)animateBounce {
    UIScrollView *scrollView = [self scrollView];
    if (scrollView == nil) {
        return;
    }
    
    if (!self.observing) {
        return;
    }
    
    [self resetScrollViewContentInset:NO animated:NO completion:nil];
    
    CGFloat centerY = kLoadingContentInset;
    CGFloat duration = 0.9;
    
    scrollView.scrollEnabled = NO;
    [self startDisplayLink];
    [scrollView dg_removeObserver:self forKeyPath:kContentOffset];
    [scrollView dg_removeObserver:self forKeyPath:kContentInset];
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.43 initialSpringVelocity:0 options:0 animations:^{
        
        CGPoint c = self.cControlPointView.center;
        c.y = centerY;
        self.cControlPointView.center = c;
        
        CGPoint c2 = self.l1ControlPointView.center;
        c2.y = centerY;
        self.l1ControlPointView.center = c2;
        
        CGPoint c3 = self.l2ControlPointView.center;
        c3.y = centerY;
        self.l2ControlPointView.center = c3;
        
        CGPoint c4 = self.l3ControlPointView.center;
        c4.y = centerY;
        self.l3ControlPointView.center = c4;
        
        CGPoint c5 = self.r1ControlPointView.center;
        c5.y = centerY;
        self.r1ControlPointView.center = c5;
        
        CGPoint c6 = self.r2ControlPointView.center;
        c6.y = centerY;
        self.r2ControlPointView.center = c6;
        
        CGPoint c7 = self.r3ControlPointView.center;
        c7.y = centerY;
        self.r3ControlPointView.center = c7;
        
    } completion:^(BOOL finished) {
        [self stopDisplayLink];
        [self resetScrollViewContentInset:YES animated:NO completion:nil];
        UIScrollView *scrollView = [self scrollView];
        if (scrollView != nil) {
            [scrollView dg_addObserver:self forKeyPath:kContentOffset];
            scrollView.scrollEnabled = YES;
        }
        self.state = DGElasticPullToRefreshStateLoading;
    }];
    
    self.bounceAnimationHelperView.center = CGPointMake(0, self.originalContentInsetTop + [self currentHeight]);
    [UIView animateWithDuration:duration * 0.4 animations:^{
        self.bounceAnimationHelperView.center = CGPointMake(0, self.originalContentInsetTop + kLoadingContentInset);
    }];
}

- (void)layoutLoadingView {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGFloat loadingViewSize = kLoadingViewSize;
    CGFloat minOriginY = (kLoadingContentInset - loadingViewSize)/2.0;
    CGFloat originY = MAX(MIN((height - loadingViewSize) / 2.0, minOriginY), 0);
    self.loadingView.frame = CGRectMake((width - loadingViewSize) / 2.0, originY,
                                        loadingViewSize, loadingViewSize);
    
    self.loadingView.maskLayer.frame = [self convertRect:self.shapeLayer.frame toView:self.loadingView];
    self.loadingView.maskLayer.path = self.shapeLayer.path;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIScrollView *scrollView = [self scrollView];
    if (self.state != DGElasticPullToRefreshStateAnimatingBounce) {
        CGFloat width = scrollView.bounds.size.width;
        CGFloat height = [self currentHeight];
     
        self.frame = CGRectMake(0, -height, width, height);
        if (self.state == DGElasticPullToRefreshStateLoading ||
            self.state == DGElasticPullToRefreshStateAnimatingToStopped) {
            self.cControlPointView.center = CGPointMake(width / 2.0, height);
            self.l1ControlPointView.center = CGPointMake(0.0, height);
            self.l2ControlPointView.center = CGPointMake(0.0, height);
            self.l3ControlPointView.center = CGPointMake(0.0, height);
            self.r1ControlPointView.center = CGPointMake(width, height);
            self.r2ControlPointView.center = CGPointMake(width, height);
            self.r3ControlPointView.center = CGPointMake(width, height);

        } else {
            CGFloat locationX = [scrollView.panGestureRecognizer locationInView:scrollView].x;

            CGFloat waveHeight = [self currentWaveHeight];
            CGFloat baseHeight = self.bounds.size.height - waveHeight;

            CGFloat minLeftX = MIN((locationX - width / 2.0) * 0.28, 0.0);
            CGFloat maxRightX = MAX(width + (locationX - width / 2.0) * 0.28, width);

            CGFloat leftPartWidth = locationX - minLeftX;
            CGFloat rightPartWidth = maxRightX - locationX;

            self.cControlPointView.center = CGPointMake(locationX , baseHeight + waveHeight * 1.36);
            self.l1ControlPointView.center = CGPointMake(minLeftX + leftPartWidth * 0.71, baseHeight + waveHeight * 0.64);
            self.l2ControlPointView.center = CGPointMake(minLeftX + leftPartWidth * 0.44, baseHeight);
            self.l3ControlPointView.center = CGPointMake(minLeftX, baseHeight);
            self.r1ControlPointView.center = CGPointMake(maxRightX - rightPartWidth * 0.71,
                                                         baseHeight + waveHeight * 0.64);
            self.r2ControlPointView.center = CGPointMake(maxRightX - (rightPartWidth * 0.44), baseHeight);
            self.r3ControlPointView.center = CGPointMake(maxRightX, baseHeight);
        }
        self.shapeLayer.frame = CGRectMake(0.0,0.0,width,height);
        self.shapeLayer.path = [self currentPath];
        [self layoutLoadingView];

    }
}

@end
