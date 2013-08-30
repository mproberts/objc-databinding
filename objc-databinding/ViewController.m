//
//  ViewController.m
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-29.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Databinding.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)init
{
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        [self setupItems];
        
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(changeRandomCell) userInfo:nil repeats:YES];
        
        [self.view addSubview:self.tableView];
    }
    
    return self;
}

- (void)setupItems
{
    _boundObjects = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 100; ++i) {
        NSMutableDictionary *obj = [[NSMutableDictionary alloc] init];
        
        [obj setObject:[NSString stringWithFormat:@"Title %d", i+1] forKey:@"title"];
        
        [_boundObjects addObject:obj];
        
        [self changeCellAtIndex:i];
    }
}

- (void)changeRandomCell
{
    int index = arc4random() % _boundObjects.count;
    
    [self changeCellAtIndex:index];
}

- (void)changeCellAtIndex:(int)index
{
    NSArray *colors = @[@"blue", @"purple", @"green", @"red", @"yellow"];
    
    NSMutableDictionary *item = [_boundObjects objectAtIndex:index];
    NSString *colorName = nil;
    
    int colorIndex = arc4random() % (colors.count + 1) - 1;
    
    if (colorIndex < 0) {
        colorName = nil;
    }
    else {
        colorName = [colors objectAtIndex:colorIndex];
    }
    
    if (!colorName) {
        [item removeObjectForKey:@"color"];
    }
    else {
        [item setObject:colorName forKey:@"color"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _boundObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"BoundObjectID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        cell.imageView.frame = CGRectMake(0, 0, 44, 44);
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.clipsToBounds = YES;
        
        __block UIImageView *imageView = cell.imageView;
        
        // animate the swap
        [imageView watchKeyPath:@"image" onObject:cell.imageView andCallback:^(id value, id oldValue) {
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
                [UIView animateWithDuration:0.3 delay:0.0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     overlayView.alpha = 0.0;
                                 }
                                 completion:^(BOOL finished) {
                                     if (finished) {
                                         [overlayView removeFromSuperview];
                                     }
                                 }];
            }
        }];
    }
    
    id item = [_boundObjects objectAtIndex:indexPath.row];
    
    return [self bindCell:cell toItem:item];
}

- (UITableViewCell *)bindCell:(UITableViewCell *)cell toItem:(id)item
{
    // bind data
    [cell.textLabel bindKeyPath:@"text" toKeyPath:@"title" onObject:item defaultValue:@"Default"];
    [cell.detailTextLabel bindKeyPath:@"text" toKeyPath:@"color" onObject:item defaultValue:@"n/a"];
    
    cell.imageView.image = nil;
    [cell.imageView bindKeyPath:@"image" toKeyPath:@"color" onObject:item transformedBy:^UIImage *(NSString *color) {
        if (!color) {
            return [UIImage imageNamed:@"img-default.png"];
        }
        
        return [UIImage imageNamed:[NSString stringWithFormat:@"img-%@.png", color]];
    }];
    
    return cell;
}

@end
