//
//  UILabel+Databinding.h
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-30.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Databinding.h"
#import "NSObject+Databinding.h"

@interface UILabel (Databinding)

- (NSString *)textBinding;

- (void)setTextBinding:(NSString *)textBinding;

- (void)setTextBinding:(NSString *)textBinding defaultValue:(NSString *)textBindingDefault;

- (NSString *)textBindingDefault;

- (void)setTextBindingDefault:(NSString *)textBindingDefault;

- (void (^)(id, transform_completed_t))textBindingTransform;

- (void)setTextBindingTransform:(void (^)(id, transform_completed_t))transform;

@end
