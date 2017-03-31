//
//  UIView+DGElasticPullToRefreshExtensions.m
//  DGElasticPullToRefreshExample
//
//  Created by Smolski, Aliaksei on 31.03.17.
//  Copyright © 2017 Danil Gontovnik. All rights reserved.
//

#import "UIView+DGElasticPullToRefreshExtensions.h"

@implementation UIView (DGElasticPullToRefreshExtensions)
- (CGPoint)dg_center:(BOOL) userPresentationIfPosible {
    if (userPresentationIfPosible) {
        CALayer *presentationLayer = self.layer.presentationLayer;
        return presentationLayer.position;
    }
    return self.center;
}
@end
