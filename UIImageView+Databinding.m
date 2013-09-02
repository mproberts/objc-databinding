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

@implementation UIImageView (Databinding)

DECLARE_BINDABLE(@"image", image, Image, UIImage *)

@end
