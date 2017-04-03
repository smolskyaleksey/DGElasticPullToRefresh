//
//  UIScrollView+DGElasticPullToRefreshExtensions.m
//  DGElasticPullToRefreshExample
//
//  Created by Smolski, Aliaksei on 31.03.17.
//  Copyright © 2017 Danil Gontovnik. All rights reserved.
//

#import "UIScrollView+DGElasticPullToRefreshExtensions.h"
#import "DGElasticPullToRefreshView.h"
#import <objc/runtime.h>
static char kPullToRefreshViewKey;

@implementation UIScrollView (DGElasticPullToRefreshExtensions)

- (void)setPullToRefreshView:(DGElasticPullToRefreshView *)loadViewController {
    objc_setAssociatedObject(self, &kPullToRefreshViewKey, loadViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (DGElasticPullToRefreshView *)pullToRefreshView {
    return objc_getAssociatedObject(self, &kPullToRefreshViewKey);
}



- (void)dg_addPullToRefreshWithActionHandler:(void (^)())actionHandler
                                 loadingView:(DGElasticPullToRefreshLoadingView *)loadingView {
    self.multipleTouchEnabled = NO;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    DGElasticPullToRefreshView *pullToRefreshView = [DGElasticPullToRefreshView new];
    self.pullToRefreshView = pullToRefreshView;
    pullToRefreshView.actionHandler = actionHandler;
    pullToRefreshView.loadingView = loadingView;
    [self addSubview:pullToRefreshView];
    pullToRefreshView.observing = YES;
}

- (void)dg_removePullToRefresh {
    [self.pullToRefreshView disassociateDisplayLink];
    self.pullToRefreshView.observing = NO;
    [self.pullToRefreshView removeFromSuperview];
}

- (void)dg_setPullToRefreshBackgroundColor:(UIColor *)color {
    self.pullToRefreshView.backgroundColor = color;
}

- (void)dg_setPullToRefreshFillColor:(UIColor *)color {
    self.pullToRefreshView.fillColor = color;
}

- (void)dg_stopLoading {
    [self.pullToRefreshView stopLoading];
}

@end
