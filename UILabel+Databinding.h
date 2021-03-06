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

DEFINE_BINDABLE(@"text", text, Text, NSString *)

@end
