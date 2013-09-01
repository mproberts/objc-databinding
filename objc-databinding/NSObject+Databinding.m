//
//  NSObject+Databinding.m
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-29.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import "NSObject+Databinding.h"
#import <objc/runtime.h>
#include <pthread.h>

#define KEY_PATH_BINDINGS_KEY "objc-databinding.KEY_PATH_BINDINGS_KEY"
#define KEY_PATH_WATCHERS_KEY "objc-databinding.KEY_PATH_WATCHERS_KEY"

#define LOGGING 0

#if LOGGING
#define ODB_LOG(x, ...) NSLog(x, __VA_ARGS__)
#else
#define ODB_LOG(x, ...)
#endif

BOOL run_on_main(void (^block)(void))
{
    if (pthread_main_np()) {
        block();
        
        return YES;
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
        
        return NO;
    }
}

@interface ODBDataBinding : NSObject {
    BOOL _isBound;
}

@property (nonatomic, weak) id targetObject;
@property (nonatomic, retain) id sourceObject;
@property (nonatomic, retain) id defaultValue;
@property (nonatomic, retain) NSString *targetKeyPath;
@property (nonatomic, retain) NSString *sourceKeyPath;
@property (nonatomic, assign) int permittedTransform;
@property (nonatomic, copy) void (^transformBlock)(id, transform_completed_t);
@property (nonatomic, copy) void (^watcherBlock)(id, id);

- (id)initWithSource:(id)sourceObject
       sourceKeyPath:(NSString *)sourceKeyPath
              target:(id)targetObject
       targetKeyPath:(NSString *)targetKeyPath
        defaultValue:(id)defaultValue
      transformBlock:(void (^)(id, transform_completed_t))transformBlock
        watcherBlock:(void (^)(id, id))watcherBlock;

- (void)bindNewSource:(id)sourceObject;

- (void)bindToObject;

- (void)unbind;

@end

@implementation ODBDataBinding

- (id)initWithSource:(id)sourceObject
       sourceKeyPath:(NSString *)sourceKeyPath
              target:(id)targetObject
       targetKeyPath:(NSString *)targetKeyPath
        defaultValue:(id)defaultValue
      transformBlock:(void (^)(id, transform_completed_t))transformBlock
        watcherBlock:(void (^)(id, id))watcherBlock
{
    if (self = [super init]) {
        self.sourceObject = sourceObject;
        self.sourceKeyPath = sourceKeyPath;
        self.targetObject = targetObject;
        self.targetKeyPath = targetKeyPath;
        self.defaultValue = defaultValue;
        self.transformBlock = transformBlock;
        self.watcherBlock = watcherBlock;
    }
    
    return self;
}

- (void)dealloc
{
    [self unbind];
}

- (void)bindNewSource:(id)sourceObject
{
    [self unbind];
    
    self.sourceObject = sourceObject;
    
    [self bindToObject];
}

- (void)bindToObject
{
    if (!_isBound) {
        if (self.sourceObject) {
            [self.sourceObject addObserver:self
                                forKeyPath:self.sourceKeyPath
                                   options:NSKeyValueObservingOptionNew
                                          |NSKeyValueObservingOptionOld
                                          |NSKeyValueObservingOptionInitial
                                   context:NULL];
        }
        else {
            [self observeValueForKeyPath:self.sourceKeyPath
                                ofObject:self.sourceObject
                                  change:@{
                                     NSKeyValueChangeOldKey: [NSNull null],
                                     NSKeyValueChangeNewKey: [NSNull null]
                                 }
                                 context:NULL];
        }
        
        _isBound = YES;
    }
}

- (void)unbind
{
    if (_isBound) {
        [self.sourceObject removeObserver:self forKeyPath:self.sourceKeyPath context:NULL];
        
        ODB_LOG(@"Unbinding from 0x%x (%@ -> %@)", (int)self.sourceObject, self.sourceKeyPath, self.targetKeyPath);
        
        _isBound = NO;
        self.permittedTransform = 0;
    }
}

- (void)transformValue:(id)value callback:(transform_completed_t)callback
{
    __block BOOL returned = NO;
    id existingValue = [self.targetObject valueForKeyPath:self.targetKeyPath];
    
    if (self.transformBlock != nil) {
        self.transformBlock(value, ^(id resultValue) {
            returned = YES;
            
            if (!resultValue || resultValue == [NSNull null]) {
                resultValue = self.defaultValue;
            }
            
            callback(resultValue);
        });
        
        if (!returned && existingValue == nil) {
            callback(self.defaultValue);
        }
    }
    else {
        if (!value || value == [NSNull null]) {
            value = self.defaultValue;
        }
        
        callback(value);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:self.sourceKeyPath]) {
        NSString *targetKeyPath = self.targetKeyPath;
        id target = self.targetObject;
        id value = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (value == [NSNull null]) {
            value = nil;
        }
        
        if (self.watcherBlock != nil) {
            id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
            
            if (oldValue == [NSNull null]) {
                oldValue = nil;
            }
            
            void (^observerBlock)() = ^{
                self.watcherBlock(value, oldValue);
            };
            
            if (!run_on_main(observerBlock)) {
                ODB_LOG(@"Changed off main thread %@ on 0x%x", keyPath, (int)object);
            }
        }
        else {
            __block ODBDataBinding *this = self;
            int transformToken = ++self.permittedTransform;
            
            self.permittedTransform = transformToken;
            
            [self transformValue:value callback:^(id transformedValue) {
                void (^observerBlock)() = ^{
                    [target setValue:transformedValue forKeyPath:targetKeyPath];
                };
                
                // allow this transformation to be applied
                if (transformToken == this.permittedTransform) {
                    if (!run_on_main(observerBlock)) {
                        ODB_LOG(@"Changed off main thread %@ on 0x%x", keyPath, (int)object);
                    }
                }
                else {
                    ODB_LOG(@"Transform returned after next change %@ on 0x%x", keyPath, (int)object);
                }
            }];
        }
    }
}

@end

@interface NSObject (ODBPrivate)

- (void)applyBinding:(ODBDataBinding *)binding;

@end

@implementation NSObject (DataBinding)

- (void)bindKeyPath:(NSString *)targetKeyPath toKeyPath:(NSString *)sourceKeyPath onObject:(id)object
{
    [self bindKeyPath:targetKeyPath
            toKeyPath:sourceKeyPath
             onObject:object
         defaultValue:nil];
}

- (void)bindKeyPath:(NSString *)targetKeyPath toKeyPath:(NSString *)sourceKeyPath onObject:(id)object defaultValue:(id)defaultValue
{
    ODBDataBinding *binding = [[ODBDataBinding alloc] initWithSource:object
                                                       sourceKeyPath:sourceKeyPath
                                                              target:self
                                                       targetKeyPath:targetKeyPath
                                                        defaultValue:defaultValue
                                                      transformBlock:nil
                                                        watcherBlock:nil];
    
    [self applyBinding:binding];
}

- (void)bindKeyPath:(NSString *)targetKeyPath toKeyPath:(NSString *)sourceKeyPath onObject:(id)object transformedBy:(id (^)(id))transformBlock
{
    [self bindKeyPath:targetKeyPath
            toKeyPath:sourceKeyPath
             onObject:object
   transformedByAsync:^(id value, transform_completed_t callback) {
       callback(transformBlock(value));
    }];
}

- (void)bindKeyPath:(NSString *)targetKeyPath toKeyPath:(NSString *)sourceKeyPath onObject:(id)object transformedByAsync:(void (^)(id, transform_completed_t))transformBlock
{
    [self bindKeyPath:targetKeyPath
            toKeyPath:sourceKeyPath
             onObject:object
         defaultValue:nil
   transformedByAsync:transformBlock];
}

- (void)bindKeyPath:(NSString *)targetKeyPath toKeyPath:(NSString *)sourceKeyPath onObject:(id)object defaultValue:(id)defaultValue transformedByAsync:(void (^)(id, transform_completed_t))transformBlock
{
    ODBDataBinding *binding = [[ODBDataBinding alloc] initWithSource:object
                                                       sourceKeyPath:sourceKeyPath
                                                              target:self
                                                       targetKeyPath:targetKeyPath
                                                        defaultValue:defaultValue
                                                      transformBlock:transformBlock
                                                        watcherBlock:nil];
    
    [self applyBinding:binding];
}

- (void)watchKeyPath:(id)keyPath onObject:(id)object andCallback:(void (^)(id, id))callback
{
    ODBDataBinding *binding = [[ODBDataBinding alloc] initWithSource:self
                                                       sourceKeyPath:keyPath
                                                              target:nil
                                                       targetKeyPath:nil
                                                        defaultValue:nil
                                                      transformBlock:nil
                                                        watcherBlock:callback];
    
    [self applyWatcherBinding:binding];
}

- (void)applyWatcherBinding:(ODBDataBinding *)binding
{
    NSMutableArray *bindings = objc_getAssociatedObject(self, KEY_PATH_WATCHERS_KEY);
    
    if (bindings == nil) {
        bindings = [[NSMutableArray alloc] init];
        
        objc_setAssociatedObject(self, KEY_PATH_WATCHERS_KEY, bindings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // attach the new binding
    [bindings addObject:binding];
    
    // apply the binding to the source
    [binding bindToObject];
}

- (void)applyBinding:(ODBDataBinding *)binding
{
    NSMutableDictionary *bindings = objc_getAssociatedObject(self, KEY_PATH_BINDINGS_KEY);
    
    if (bindings == nil) {
        bindings = [[NSMutableDictionary alloc] init];
        
        objc_setAssociatedObject(self, KEY_PATH_BINDINGS_KEY, bindings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    ODBDataBinding *oldBinding = nil;
    
    // remove old binding before adding a new one
    if ([bindings objectForKey:binding.targetKeyPath] != nil) {
        oldBinding = [bindings objectForKey:binding.targetKeyPath];
        
        [bindings removeObjectForKey:binding.targetKeyPath];
    }
    
    // attach the new binding
    [bindings setObject:binding forKey:binding.targetKeyPath];
    
    [oldBinding unbind];
    
    // apply the binding to the source
    [binding bindToObject];
}

- (void)updateKeyPath:(NSString *)keyPath withSource:(id)source
{
    ODBDataBinding *oldBinding = nil;
    NSMutableDictionary *bindings = objc_getAssociatedObject(self, KEY_PATH_BINDINGS_KEY);
    
    if ([bindings objectForKey:keyPath] != nil) {
        oldBinding = [bindings objectForKey:keyPath];
        
        if (oldBinding) {
            [oldBinding bindNewSource:source];
        }
    }
}

- (void)unbindKeyPath:(NSString *)targetKeyPath
{
    ODBDataBinding *oldBinding = nil;
    NSMutableDictionary *bindings = objc_getAssociatedObject(self, KEY_PATH_BINDINGS_KEY);
    
    if ([bindings objectForKey:targetKeyPath] != nil) {
        oldBinding = [bindings objectForKey:targetKeyPath];
        
        [bindings removeObjectForKey:targetKeyPath];
    }
    
    [oldBinding unbind];
}

- (void)unbindAllKeyPaths
{
    NSMutableDictionary *bindings = objc_getAssociatedObject(self, KEY_PATH_BINDINGS_KEY);
    NSMutableDictionary *watchers = objc_getAssociatedObject(self, KEY_PATH_WATCHERS_KEY);
    
    objc_setAssociatedObject(self, KEY_PATH_BINDINGS_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, KEY_PATH_WATCHERS_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    for (ODBDataBinding *binding in bindings.allValues) {
        [binding unbind];
    }
    
    for (ODBDataBinding *binding in watchers) {
        [binding unbind];
    }
}

@end
