//
//  UIImageView+Transition.h
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-30.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Transition)

- (void)setTransitionWithDuration:(NSTimeInterval)duration;

- (void)setTransitionWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options;

- (void)setTransitionWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(UIImageView *, UIImageView *))animations;

@end
