//
//  UIScrollView+DGElasticPullToRefreshExtensions.h
//  DGElasticPullToRefreshExample
//
//  Created by Smolski, Aliaksei on 31.03.17.
//  Copyright © 2017 Danil Gontovnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGElasticPullToRefreshView.h"
#import "DGElasticPullToRefreshLoadingView.h"


@interface UIScrollView (DGElasticPullToRefreshExtensions)
- (void)dg_addPullToRefreshWithActionHandler:(void (^)())actionHandler loadingView:(DGElasticPullToRefreshLoadingView *)loadingView;
- (void)dg_removePullToRefresh;
- (void)dg_setPullToRefreshBackgroundColor:(UIColor *)color;
- (void)dg_setPullToRefreshFillColor:(UIColor *)color;
- (void)dg_stopLoading;

- (void)setPullToRefreshView:(DGElasticPullToRefreshView *)loadViewController;
- (DGElasticPullToRefreshView *)pullToRefreshView;
@end
