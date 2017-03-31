//
//  NSObject+DGElasticPullToRefreshExtensions.h
//  DGElasticPullToRefreshExample
//
//  Created by Smolski, Aliaksei on 31.03.17.
//  Copyright © 2017 Danil Gontovnik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (DGElasticPullToRefreshExtensions)
- (void)dg_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
- (void)dg_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
@end
