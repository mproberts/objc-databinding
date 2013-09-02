//
//  UIImageView+Transition.m
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-30.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import "UIImageView+Transition.h"
#import "NSObject+Databinding.h"

@implementation UIImageView (Transition)

- (void)setTransitionWithDuration:(NSTimeInterval)duration
{
    [self setTransitionWithDuration:duration options:UIViewAnimationOptionCurveEaseOut];
}

- (void)setTransitionWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options
{
    [self setTransitionWithDuration:duration options:options animations:^(UIImageView *overlay, UIImageView *image) {
        overlay.alpha = 0.0;
    }];
}

- (void)setTransitionWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(UIImageView *, UIImageView *))animations
{
    __block UIImageView *imageView = self;

    // animate the swap
    [imageView watchKeyPath:@"image" onObject:imageView andCallback:^(id value, id oldValue) {
        for (UIView *subview in [imageView subviews]) {
            [subview removeFromSuperview];
        }
        
        if (oldValue != nil) {
            UIImageView *overlayView = [[UIImageView alloc] initWithImage:oldValue];
            CGRect frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
            
            // create doppleganger image view
            overlayView.contentMode = imageView.contentMode;
            overlayView.frame = frame;
            overlayView.clipsToBounds = YES;
            overlayView.alpha = 1.0;
            
            for (UIView *subview in [imageView subviews]) {
                [subview removeFromSuperview];
            }
            
            [imageView addSubview:overlayView];
            
            // cross-fade
            [UIView animateWithDuration:duration delay:0.0
                                options:options
                             animations:^{
                                 animations(overlayView, imageView);
                             }
                             completion:^(BOOL finished) {
                                 if (finished) {
                                     [overlayView removeFromSuperview];
                                 }
                             }];
        }
    }];
}

@end
