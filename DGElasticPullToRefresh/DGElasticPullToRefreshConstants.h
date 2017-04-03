//
//  DGElasticPullToRefreshConstants.h
//  DGElasticPullToRefreshExample
//
//  Created by Smolski, Aliaksei on 31.03.17.
//  Copyright © 2017 Danil Gontovnik. All rights reserved.
//

#ifndef DGElasticPullToRefreshConstants_h
#define DGElasticPullToRefreshConstants_h

static NSString *const kContentOffset = @"contentOffset";
static NSString *const kContentInset = @"contentInset";
static NSString *const kFrame = @"frame";
static NSString *const kPanGestureRecognizerState = @"panGestureRecognizer.state";


CGFloat const kWaveMaxHeight = 70.0;
CGFloat const kMinOffsetToPull = 95.0;
CGFloat const kLoadingContentInset = 50.0;
CGFloat const kLoadingViewSize = 30.0;

#endif /* DGElasticPullToRefreshConstants_h */
