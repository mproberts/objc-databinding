//
//  ViewController.h
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-29.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *_boundObjects;
    NSTimer *_boundObjectPoker;
}

@property (nonatomic, strong) UITableView *tableView;

@end
