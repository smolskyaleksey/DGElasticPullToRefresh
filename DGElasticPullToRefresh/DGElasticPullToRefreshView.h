//
//  DGElasticPullToRefreshView.h
//  DGElasticPullToRefreshExample
//
//  Created by Smolski, Aliaksei on 31.03.17.
//  Copyright © 2017 Danil Gontovnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGElasticPullToRefreshLoadingView.h"

@interface DGElasticPullToRefreshView : UIView
- (void)disassociateDisplayLink;
- (void)stopLoading;
@property (nonatomic, copy) void (^actionHandler)();
@property (nonatomic, strong) DGElasticPullToRefreshLoadingView *loadingView;
@property (nonatomic, assign) BOOL observing;
@property (nonatomic, strong) UIColor *fillColor;
@end
