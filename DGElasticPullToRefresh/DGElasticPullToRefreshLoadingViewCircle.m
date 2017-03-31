//
//  DGElasticPullToRefreshLoadingViewCircle.m
//  DGElasticPullToRefreshExample
//
//  Created by Smolski, Aliaksei on 31.03.17.
//  Copyright © 2017 Danil Gontovnik. All rights reserved.
//

#import "DGElasticPullToRefreshLoadingViewCircle.h"

NSString * const kRotationAnimation = @"kRotationAnimation";

@interface DGElasticPullToRefreshLoadingViewCircle ()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) CATransform3D identityTransform;
@end

@implementation DGElasticPullToRefreshLoadingViewCircle

- (instancetype)init {
    self = [super initWithFrame:CGRectZero];
    self.shapeLayer = [CAShapeLayer new];
    self.shapeLayer.lineWidth = 1.0;
    self.shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    self.shapeLayer.strokeColor = [self.tintColor CGColor];
    self.shapeLayer.actions = @{@"strokeEnd":[NSNull null],
                                @"transform":[NSNull null]};
    self.shapeLayer.anchorPoint = CGPointMake(0.5, 0.5);
    [self.layer addSublayer:_shapeLayer];
    
    _identityTransform = CATransform3DIdentity;
    _identityTransform.m34 = 1.0 / -500.0;
    _identityTransform = CATransform3DRotate(_identityTransform,
                                             [[self class] toRadians:-90], 0.0, 0.0, 1.0);
    return self;
}

+ (CGFloat)toRadians:(CGFloat)degrees {
    return (degrees * M_PI) / 180.0;
}

- (void)setPullProgress:(CGFloat)progress {
    [super setPullProgress:progress];
    self.shapeLayer.strokeEnd = MIN(0.9 * progress, 0.9);
    if (progress > 1.0) {
        CGFloat degrees = (progress - 1.0) * 200.0;
        self.shapeLayer.transform = CATransform3DRotate([self identityTransform],
                                                        [[self class] toRadians:degrees], 0.0, 0.0, 1.0);
    } else {
        self.shapeLayer.transform = self.identityTransform;
    }
}

- (void)startAnimating {
    [super startAnimating];
    if([self.shapeLayer animationForKey:kRotationAnimation] != nil) {
        return;
    }
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:(M_PI * 2.0 + [self currentDegree])];
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = INFINITY;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [self.shapeLayer addAnimation:rotationAnimation forKey:kRotationAnimation];
}

- (void)stopLoading {
    [super stopLoading];
    [self.shapeLayer removeAnimationForKey:kRotationAnimation];
}


- (CGFloat)currentDegree {
    return [[self.shapeLayer valueForKeyPath:@"transform.rotation.z"] floatValue];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.shapeLayer.strokeColor = [self.tintColor CGColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.shapeLayer.frame = self.bounds;
    CGFloat inset = self.shapeLayer.lineWidth/2.0;
    self.shapeLayer.path = [[UIBezierPath bezierPathWithOvalInRect:
                             CGRectInset(self.shapeLayer.bounds, inset, inset)] CGPath];
}

@end
