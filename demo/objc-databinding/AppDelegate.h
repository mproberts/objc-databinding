//
//  AppDelegate.h
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-29.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
