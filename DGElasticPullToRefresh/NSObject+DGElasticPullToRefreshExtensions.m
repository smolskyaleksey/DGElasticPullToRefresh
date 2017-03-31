//
//  NSObject+DGElasticPullToRefreshExtensions.m
//  DGElasticPullToRefreshExample
//
//  Created by Smolski, Aliaksei on 31.03.17.
//  Copyright © 2017 Danil Gontovnik. All rights reserved.
//

#import "NSObject+DGElasticPullToRefreshExtensions.h"
#import <objc/runtime.h>

@implementation NSObject (DGElasticPullToRefreshExtensions)

//// MARK: -
//// MARK: Vars
//
//fileprivate struct dg_associatedKeys {
//    static var observersArray = "observers"
//}

static char observersArray;

- (void)setDg_observers:(NSMutableArray *)newValue {
    objc_setAssociatedObject(self, &observersArray, newValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSMutableArray *)dg_observers {
    NSMutableArray *observers = objc_getAssociatedObject(self, &observersArray);
    if (observers != nil) {
        return observers;
    } else {
        NSMutableArray *observers = [NSMutableArray array];
        self.dg_observers = observers;
        return observers;
    }
}


- (void)dg_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    NSDictionary *observerInfo = @{keyPath:observer};
    __block NSInteger foundIndex = -1;
    [[self dg_observers] enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
        if (obj == observerInfo) {
            foundIndex = idx;
            *stop = YES;
        }
    }];
    
    if (foundIndex == -1) {
        [[self dg_observers] addObject:observerInfo];
        [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)dg_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    NSDictionary *observerInfo = @{keyPath:observer};
    NSMutableIndexSet *indexs = [NSMutableIndexSet new];
    [[self dg_observers] enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
        if (obj == observerInfo) {
            [indexs addIndex:idx];
            [self removeObserver:observer forKeyPath:keyPath];
        }
    }];

    [[self dg_observers] removeObjectsAtIndexes:indexs];
}

@end
