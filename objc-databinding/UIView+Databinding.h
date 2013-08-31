//
//  UIView+Databinding.h
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-30.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+Databinding.h"

#define DEFINE_BINDABLE(key, property, uppercaseProperty, type) \
-(NSString *)property##KeyPath; \
-(void)set##uppercaseProperty##KeyPath:(NSString *)keyPath; \
-(void (^)(id, transform_completed_t))property##Transform; \
-(void)set##uppercaseProperty##Transform:(void (^)(id, transform_completed_t))transform; \
-(type)property##Default; \
-(void)set##uppercaseProperty##Default:(type)defaultValue; \
-(void)set##uppercaseProperty##KeyPath:(NSString *)keyPath defaultValue:(type)defaultValue; \
-(void)set##uppercaseProperty##KeyPath:(NSString *)keyPath transformedBy:(void (^)(id, transform_completed_t))transform; \
-(void)set##uppercaseProperty##KeyPath:(NSString *)keyPath defaultValue:(type)defaultValue transformedBy:(void (^)(id, transform_completed_t))transform;

#define DECLARE_BINDABLE(key, property, uppercaseProperty, type) \
-(void)_update##property##Binding { \
    NSString *keyPath = objc_getAssociatedObject(self, "_odb_"#property); \
    type defaultValue = objc_getAssociatedObject(self, "_odb_default_"#property); \
    void (^transform)(id, transform_completed_t) = objc_getAssociatedObject(self, "_odb_transform_"#property); \
    [self dataSourceBindKeyPath:key \
                      toKeyPath:keyPath \
                   defaultValue:defaultValue \
             transformedByAsync:transform]; \
} \
-(NSString *)property##KeyPath { \
    return objc_getAssociatedObject(self, "_odb_"#property); \
} \
-(void)set##uppercaseProperty##KeyPath:(NSString *)keyPath { \
    objc_setAssociatedObject(self, "_odb_"#property, keyPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    [self _update##property##Binding]; \
} \
-(void (^)(id, transform_completed_t))property##Transform { \
    return objc_getAssociatedObject(self, "_odb_transform_"#property); \
} \
-(void)set##uppercaseProperty##Transform:(void (^)(id, transform_completed_t))transform { \
    objc_setAssociatedObject(self, "_odb_transform_"#property, transform, OBJC_ASSOCIATION_COPY_NONATOMIC); \
    [self _update##property##Binding]; \
} \
-(type)property##Default { \
    return objc_getAssociatedObject(self, "_odb_default_"#property); \
} \
-(void)set##uppercaseProperty##Default:(type)defaultValue { \
    objc_setAssociatedObject(self, "_odb_default_"#property, defaultValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    [self _update##property##Binding]; \
} \
-(void)set##uppercaseProperty##KeyPath:(NSString *)keyPath defaultValue:(type)defaultValue { \
    objc_setAssociatedObject(self, "_odb_"#property, keyPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    objc_setAssociatedObject(self, "_odb_default_"#property, defaultValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    [self _update##property##Binding]; \
} \
-(void)set##uppercaseProperty##KeyPath:(NSString *)keyPath transformedBy:(void (^)(id, transform_completed_t))transform { \
    objc_setAssociatedObject(self, "_odb_"#property, keyPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    objc_setAssociatedObject(self, "_odb_transform_"#property, transform, OBJC_ASSOCIATION_COPY_NONATOMIC); \
    [self _update##property##Binding]; \
} \
-(void)set##uppercaseProperty##KeyPath:(NSString *)keyPath defaultValue:(type)defaultValue transformedBy:(void (^)(id, transform_completed_t))transform { \
    objc_setAssociatedObject(self, "_odb_"#property, keyPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    objc_setAssociatedObject(self, "_odb_default_"#property, defaultValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    objc_setAssociatedObject(self, "_odb_transform_"#property, transform, OBJC_ASSOCIATION_COPY_NONATOMIC); \
    [self _update##property##Binding]; \
}

@interface UIView (Databinding)

- (id)dataSource;

- (void)setDataSource:(id)dataSource;

- (void)dataSourceBindKeyPath:(NSString *)keyPath toKeyPath:(NSString *)dataKeyPath defaultValue:(id)defaultValue transformedByAsync:(void (^)(id, transform_completed_t))transformBlock;

DEFINE_BINDABLE(@"alpha", alpha, Alpha, NSNumber *)
DEFINE_BINDABLE(@"hidden", hidden, Hidden, NSNumber *)

@end
