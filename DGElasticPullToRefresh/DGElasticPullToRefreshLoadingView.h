//
//  DGElasticPullToRefreshLoadingView.h
//  DGElasticPullToRefreshExample
//
//  Created by Smolski, Aliaksei on 31.03.17.
//  Copyright © 2017 Danil Gontovnik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGElasticPullToRefreshLoadingView : UIView
@property (nonatomic,strong,readonly) CAShapeLayer *maskLayer;
- (void)stopLoading;
- (void)startAnimating;
- (void)setPullProgress:(CGFloat)progress;
@end
