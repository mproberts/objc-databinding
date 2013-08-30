//
//  UIImageView+Databinding.h
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-30.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+Databinding.h"

@interface UIImageView (Databinding)

- (NSString *)imageBinding;

- (void)setImageBinding:(NSString *)imageBinding;

- (void)setImageBinding:(NSString *)imageBinding defaultValue:(UIImage *)imageBindingDefault;

- (void)setImageBinding:(NSString *)imageBinding transformedBy:(void (^)(id, transform_completed_t))transform;

- (void)setImageBinding:(NSString *)imageBinding defaultValue:(UIImage *)imageBindingDefault transformedBy:(void (^)(id, transform_completed_t))transform;

- (UIImage *)imageBindingDefault;

- (void)setImageBindingDefault:(UIImage *)imageBindingDefault;

- (void (^)(id, transform_completed_t))imageBindingTransform;

- (void)setImageBindingTransform:(void (^)(id, transform_completed_t))transform;

@end
