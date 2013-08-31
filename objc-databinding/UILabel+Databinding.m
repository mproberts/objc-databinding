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

@implementation UILabel (Databinding)

DECLARE_BINDABLE(@"text", text, Text, NSString *)

@end
