//
//  DGElasticPullToRefreshLoadingView.m
//  DGElasticPullToRefreshExample
//
//  Created by Smolski, Aliaksei on 31.03.17.
//  Copyright © 2017 Danil Gontovnik. All rights reserved.
//

#import "DGElasticPullToRefreshLoadingView.h"

@interface DGElasticPullToRefreshLoadingView ()
@property (nonatomic,strong) CAShapeLayer *maskLayer;
@end

@implementation DGElasticPullToRefreshLoadingView

- (instancetype)init {
    return [super initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [super initWithFrame:CGRectZero];
}

- (void)setPullProgress:(CGFloat)progress {
    
}

- (void)startAnimating {
    
}

- (void)stopLoading {
    
}

- (CAShapeLayer *)maskLayer {
    if (_maskLayer == nil) {
        _maskLayer = [CAShapeLayer new];
        _maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
        _maskLayer.fillColor = [[UIColor blackColor] CGColor];
        _maskLayer.actions = @{@"path":[NSNull null],
                               @"position":[NSNull null],
                               @"bounds":[NSNull null]};
        self.layer.mask = _maskLayer;
    }
    return _maskLayer;
}
@end
