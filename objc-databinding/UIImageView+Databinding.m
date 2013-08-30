//
//  UIImageView+Databinding.m
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-30.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import "UIImageView+Databinding.h"
#import "UIView+Databinding.h"
#import <objc/runtime.h>

#define UIIMAGEVIEW_IMAGE_BINDING "objc-databinding.UIIMAGEVIEW_IMAGE_BINDING"
#define UIIMAGEVIEW_IMAGE_BINDING_DEFAULT "objc-databinding.UIIMAGEVIEW_IMAGE_BINDING_DEFAULT"
#define UIIMAGEVIEW_IMAGE_BINDING_TRANSFORM "objc-databinding.UIIMAGEVIEW_IMAGE_BINDING_TRANSFORM"

@implementation UIImageView (Databinding)

- (void)updateImageBinding
{
    NSString *imageBinding = objc_getAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING);
    NSString *imageBindingDefault = objc_getAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING_DEFAULT);
    void (^imageBindingTransform)(id, transform_completed_t) = objc_getAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING_TRANSFORM);
    
    [self dataSourceBindKeyPath:@"image"
                      toKeyPath:imageBinding
                   defaultValue:imageBindingDefault
             transformedByAsync:imageBindingTransform];
}

- (NSString *)imageBinding
{
    return objc_getAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING);
}

- (void)setImageBinding:(NSString *)imageBinding
{
    objc_setAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING, imageBinding, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self updateImageBinding];
}

- (void)setImageBinding:(NSString *)imageBinding defaultValue:(UIImage *)imageBindingDefault
{
    objc_setAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING, imageBinding, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING_DEFAULT, imageBindingDefault, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self updateImageBinding];
}

- (void)setImageBinding:(NSString *)imageBinding transformedBy:(void (^)(id, transform_completed_t))transform
{
    objc_setAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING, imageBinding, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING_TRANSFORM, transform, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self updateImageBinding];
}

- (void)setImageBinding:(NSString *)imageBinding defaultValue:(UIImage *)imageBindingDefault transformedBy:(void (^)(id, transform_completed_t))transform
{
    objc_setAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING, imageBinding, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING_DEFAULT, imageBindingDefault, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING_TRANSFORM, transform, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self updateImageBinding];
}

- (UIImage *)imageBindingDefault
{
    return objc_getAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING_DEFAULT);
}

- (void)setImageBindingDefault:(UIImage *)imageBindingDefault
{
    objc_setAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING_DEFAULT, imageBindingDefault, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self updateImageBinding];
}

- (void (^)(id, transform_completed_t))imageBindingTransform
{
    return objc_getAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING_TRANSFORM);
}

- (void)setImageBindingTransform:(void (^)(id, transform_completed_t))transform
{
    objc_setAssociatedObject(self, UIIMAGEVIEW_IMAGE_BINDING_TRANSFORM, transform, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self updateImageBinding];
}

@end
