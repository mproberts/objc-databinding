//
//  NSObject+Databinding.h
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-29.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^transform_completed_t)(id value);

@interface NSObject (DataBinding)

- (void)bindKeyPath:(NSString *)targetKeyPath toKeyPath:(NSString *)sourceKeyPath onObject:(id)object;

- (void)bindKeyPath:(NSString *)targetKeyPath toKeyPath:(NSString *)sourceKeyPath onObject:(id)object defaultValue:(id)defaultValue;

- (void)bindKeyPath:(NSString *)targetKeyPath toKeyPath:(NSString *)sourceKeyPath onObject:(id)object transformedBy:(id (^)(id))transformBlock;

- (void)bindKeyPath:(NSString *)targetKeyPath toKeyPath:(NSString *)sourceKeyPath onObject:(id)object transformedByAsync:(void (^)(id, transform_completed_t))transformBlock;

- (void)bindKeyPath:(NSString *)targetKeyPath toKeyPath:(NSString *)sourceKeyPath onObject:(id)object defaultValue:(id)defaultValue transformedByAsync:(void (^)(id, transform_completed_t))transformBlock;

- (void)unbindKeyPath:(NSString *)targetKeyPath;

- (void)watchKeyPath:(id)keyPath onObject:(id)object andCallback:(void (^)(id, id))callback;

- (void)unbindAllKeyPaths;

@end
