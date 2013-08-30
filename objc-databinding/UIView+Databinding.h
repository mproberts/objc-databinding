//
//  UIView+Databinding.h
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-30.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+Databinding.h"

@interface UIView (Databinding)

- (id)dataSource;

- (void)setDataSource:(id)dataSource;

- (void)dataSourceBindKeyPath:(NSString *)keyPath toKeyPath:(NSString *)dataKeyPath defaultValue:(id)defaultValue transformedByAsync:(void (^)(id, transform_completed_t))transformBlock;

@end
