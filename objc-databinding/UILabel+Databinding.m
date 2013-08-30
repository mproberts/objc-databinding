//
//  UILabel+Databinding.m
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-30.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import "UILabel+Databinding.h"
#import <objc/runtime.h>
#include <pthread.h>

#define UILABEL_TEXT_BINDING "objc-databinding.UILABEL_TEXT_BINDING"
#define UILABEL_TEXT_BINDING_DEFAULT "objc-databinding.UILABEL_TEXT_BINDING_DEFAULT"
#define UILABEL_TEXT_BINDING_TRANSFORM "objc-databinding.UILABEL_TEXT_BINDING_TRANSFORM"

@implementation UILabel (Databinding)

- (void)updateTextBinding
{
    NSString *textBinding = objc_getAssociatedObject(self, UILABEL_TEXT_BINDING);
    NSString *textBindingDefault = objc_getAssociatedObject(self, UILABEL_TEXT_BINDING_DEFAULT);
    void (^textBindingTransform)(id, transform_completed_t) = objc_getAssociatedObject(self, UILABEL_TEXT_BINDING_TRANSFORM);
    
    [self dataSourceBindKeyPath:@"text" toKeyPath:textBinding defaultValue:textBindingDefault transformedByAsync:textBindingTransform];
}

- (NSString *)textBinding
{
    return objc_getAssociatedObject(self, UILABEL_TEXT_BINDING);
}

- (void)setTextBinding:(NSString *)textBinding
{
    objc_setAssociatedObject(self, UILABEL_TEXT_BINDING, textBinding, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self updateTextBinding];
}

- (void)setTextBinding:(NSString *)textBinding defaultValue:(NSString *)textBindingDefault
{
    objc_setAssociatedObject(self, UILABEL_TEXT_BINDING, textBinding, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, UILABEL_TEXT_BINDING_DEFAULT, textBindingDefault, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self updateTextBinding];
}

- (NSString *)textBindingDefault
{
    return objc_getAssociatedObject(self, UILABEL_TEXT_BINDING_DEFAULT);
}

- (void)setTextBindingDefault:(NSString *)textBindingDefault
{
    objc_setAssociatedObject(self, UILABEL_TEXT_BINDING_DEFAULT, textBindingDefault, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self updateTextBinding];
}

- (void (^)(id, transform_completed_t))textBindingTransform
{
    return objc_getAssociatedObject(self, UILABEL_TEXT_BINDING_TRANSFORM);
}

- (void)setTextBindingTransform:(void (^)(id, transform_completed_t))transform
{
    objc_setAssociatedObject(self, UILABEL_TEXT_BINDING_TRANSFORM, transform, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self updateTextBinding];
}

@end
