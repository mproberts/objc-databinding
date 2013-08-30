//
//  UIView+Databinding.m
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-30.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import "UIView+Databinding.h"
#import "NSObject+Databinding.h"
#import <objc/runtime.h>
#include <pthread.h>

#define DATA_SOURCE_KEY "objc-databinding.DATA_SOURCE_KEY"
#define CONTROL_DATA_BINDINGS "objc-databinding.CONTROL_DATA_BINDINGS"

@implementation UIView (Databinding)

- (void)updateDataSource:(id)dataSource atRoot:(UIView *)root
{
    if (root != self) {
        id existingDataSource = self.dataSource;
        
        if (existingDataSource != nil) {
            // don't update view or subviews, they are otherwise bound
            return;
        }
    }
    
    // update all bindings on root node
    NSMutableArray *bindings = objc_getAssociatedObject(self, CONTROL_DATA_BINDINGS);
    
    if (bindings != nil) {
        for (NSString *targetKeyPath in bindings) {
            if ([self respondsToSelector:@selector(updateKeyPath:withSource:)]) {
                [self performSelector:@selector(updateKeyPath:withSource:) withObject:targetKeyPath withObject:dataSource];
            }
        }
    }

    // update bindings on all children
    for (UIView *subview in self.subviews) {
        [subview updateDataSource:dataSource atRoot:root];
    }
}

- (id)dataSource
{
    id dataSource = objc_getAssociatedObject(self, DATA_SOURCE_KEY);
    
    return dataSource;
}

- (void)setDataSource:(id)dataSource
{
    objc_setAssociatedObject(self, DATA_SOURCE_KEY, dataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    id root = self;
    
    if (dataSource == nil) {
        // update with parent datasource
        id parentDataSource = nil;
        
        UIView *parent = self.superview;
        
        while (parent != nil) {
            parentDataSource = parent.dataSource;
            
            // found a datasource and root
            if (parentDataSource != nil) {
                break;
            }
            
            parent = parent.superview;
        }
        
        // bind children to this parent instead
        if (parent != nil && parentDataSource != nil) {
            root = parent;
            dataSource = parentDataSource;
        }
    }
    
    // update subviews
    [self updateDataSource:dataSource atRoot:root];
}

- (id)findDataSource
{
    id dataSource = self.dataSource;
    UIView *parent = self.superview;
    
    while (parent != nil && dataSource == nil) {
        dataSource = parent.dataSource;
        parent = parent.superview;
    }
    
    return dataSource;
}

- (void)dataSourceBindKeyPath:(NSString *)keyPath toKeyPath:(NSString *)dataKeyPath defaultValue:(id)defaultValue transformedByAsync:(void (^)(id, transform_completed_t))transformBlock
{
    NSMutableArray *bindings = objc_getAssociatedObject(self, CONTROL_DATA_BINDINGS);
    
    if (bindings == nil) {
        bindings = [[NSMutableArray alloc] init];
        
        objc_setAssociatedObject(self, CONTROL_DATA_BINDINGS, bindings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if (![bindings containsObject:keyPath]) {
        [bindings addObject:keyPath];
    }
    
    id dataSource = [self findDataSource];
    
    [self bindKeyPath:keyPath
            toKeyPath:dataKeyPath
             onObject:dataSource
         defaultValue:defaultValue
   transformedByAsync:transformBlock];
}

@end
