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
#define DEALLOC_WATCHERS_KEY "objc-databinding.DEALLOC_WATCHERS_KEY"

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

@interface ODBDeallocCallback : NSObject

@property (nonatomic, copy) void (^deallocBlock)(id);
@property (nonatomic, unsafe_unretained) id object;

- (id)initWithCallback:(void (^)(id))callback onObject:(id)object;

@end

@implementation ODBDeallocCallback

- (id)initWithCallback:(void (^)(id))callback onObject:(id)object
{
    if (self = [super init]) {
        self.deallocBlock = callback;
        self.object = object;
    }
    
    return self;
}

- (void)dealloc
{
    self.deallocBlock(self.object);
}

@end

@interface ODBDataBinding : NSObject {
    BOOL _isBound;
}

@property (nonatomic, weak) id targetObject;
@property (nonatomic, retain) id sourceObject;
@property (nonatomic, retain) id defaultValue;
@property (nonatomic, retain) NSString *targetKeyPath;
@property (nonatomic, retain) NSString *sourceKeyPath;
@property (nonatomic, copy) id (^transformBlock)(id);
@property (nonatomic, copy) void (^watcherBlock)(id, id);

- (id)initWithSource:(id)sourceObject
       sourceKeyPath:(NSString *)sourceKeyPath
              target:(id)targetObject
       targetKeyPath:(NSString *)targetKeyPath
        defaultValue:(id)defaultValue
      transformBlock:(id (^)(id))transformBlock
        watcherBlock:(void (^)(id, id))watcherBlock;

- (void)bindToObject;

- (void)unbind;

@end

@implementation ODBDataBinding

- (id)initWithSource:(id)sourceObject
       sourceKeyPath:(NSString *)sourceKeyPath
              target:(id)targetObject
       targetKeyPath:(NSString *)targetKeyPath
        defaultValue:(id)defaultValue
      transformBlock:(id (^)(id))transformBlock
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

- (void)bindToObject
{
    if (!_isBound) {
        [self.sourceObject addObserver:self
                            forKeyPath:self.sourceKeyPath
                               options:NSKeyValueObservingOptionNew
                                      |NSKeyValueObservingOptionOld
                                      |NSKeyValueObservingOptionInitial
                               context:NULL];
        
        _isBound = YES;
    }
}

- (void)unbind
{
    if (_isBound) {
        [self.sourceObject removeObserver:self forKeyPath:self.sourceKeyPath context:NULL];
        
        ODB_LOG(@"Unbinding from 0x%x (%@ -> %@)", (int)self.sourceObject, self.sourceKeyPath, self.targetKeyPath);
        
        _isBound = NO;
    }
}

- (id)transformValue:(id)value
{
    if (!value || value == [NSNull null]) {
        value = self.defaultValue;
    }
    
    if (self.transformBlock != nil) {
        value = self.transformBlock(value);
    }
    
    return value;
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
        
        void (^observerBlock)() = nil;
        
        if (self.watcherBlock != nil) {
            id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
            
            if (oldValue == [NSNull null]) {
                oldValue = nil;
            }
            
            observerBlock = ^{
                self.watcherBlock(value, oldValue);
            };
        }
        else {
            value = [self transformValue:value];
            
            observerBlock = ^{
                [target setValue:value forKeyPath:targetKeyPath];
            };
        }
        
        if (!run_on_main(observerBlock)) {
            ODB_LOG(@"Changed off main thread %@ on 0x%x", keyPath, (int)object);
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
    ODBDataBinding *binding = [[ODBDataBinding alloc] initWithSource:object
                                                       sourceKeyPath:sourceKeyPath
                                                              target:self
                                                       targetKeyPath:targetKeyPath
                                                        defaultValue:nil
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
    
    // remove old binding before adding a new one
    if ([bindings objectForKey:binding.targetKeyPath] != nil) {
        ODBDataBinding *oldBinding = [bindings objectForKey:binding.targetKeyPath];
        
        [oldBinding unbind];
        
        [bindings removeObjectForKey:binding.targetKeyPath];
    }
    
    // attach the new binding
    [bindings setObject:binding forKey:binding.targetKeyPath];
    
    // apply the binding to the source
    [binding bindToObject];
}

- (void)unbindKeyPath:(NSString *)targetKeyPath
{
    NSMutableDictionary *bindings = objc_getAssociatedObject(self, KEY_PATH_BINDINGS_KEY);
    
    if ([bindings objectForKey:targetKeyPath] != nil) {
        ODBDataBinding *oldBinding = [bindings objectForKey:targetKeyPath];
        
        [oldBinding unbind];
        
        [bindings removeObjectForKey:targetKeyPath];
    }
}

- (void)unbindAllKeyPaths
{
    NSMutableDictionary *bindings = objc_getAssociatedObject(self, KEY_PATH_BINDINGS_KEY);
    NSMutableDictionary *watchers = objc_getAssociatedObject(self, KEY_PATH_WATCHERS_KEY);
    
    for (ODBDataBinding *binding in bindings.allValues) {
        [binding unbind];
    }
    
    for (ODBDataBinding *binding in watchers) {
        [binding unbind];
    }
    
    objc_setAssociatedObject(self, KEY_PATH_BINDINGS_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, KEY_PATH_WATCHERS_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)afterDeallocCall:(void (^)(id))callback
{
    ODBDeallocCallback *deallocCallback = [[ODBDeallocCallback alloc] initWithCallback:callback onObject:self];
    
    NSMutableArray *bindings = objc_getAssociatedObject(self, DEALLOC_WATCHERS_KEY);
    
    if (bindings == nil) {
        bindings = [[NSMutableArray alloc] init];
        
        objc_setAssociatedObject(self, DEALLOC_WATCHERS_KEY, bindings, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [bindings addObject:deallocCallback];
}

@end
