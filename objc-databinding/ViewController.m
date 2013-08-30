//
//  ViewController.m
//  objc-databinding
//
//  Created by Michael Roberts on 2013-08-29.
//  Copyright (c) 2013 Mike Roberts. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+Transition.h"
#import "ObjcDatabinding.h"

#define DEMO_CELL_IDENTIFIER @"BoundObjectID"

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
        
        [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(changeRandomCell) userInfo:nil repeats:YES];
        
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

- (UITableViewCell *)createCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:DEMO_CELL_IDENTIFIER];
    
    cell.imageView.frame = CGRectMake(0, 0, 44, 44);
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    
    [cell.imageView setTransitionWithDuration:0.7];
    
    cell.textLabel.textBinding = @"title";
    
    [cell.detailTextLabel setTextBinding:@"color" defaultValue:@"Not Available"];
    
    [cell.imageView setImageBinding:@"color"
                       defaultValue:[UIImage imageNamed:@"img-default.png"]
                      transformedBy:^(NSString *color, transform_completed_t callback) {
                          if (color) {
                              void (^loadBlock)() = ^{
                                  callback([UIImage imageNamed:[NSString stringWithFormat:@"img-%@.png", color]]);
                              };
                              
                              // for fun, delay the load ~1/3 of th time
                              if (arc4random() % 3 == 0) {
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), loadBlock);
                              }
                              else {
                                  loadBlock();
                              }
                          }
                          else {
                              callback(nil);
                          }
                      }];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DEMO_CELL_IDENTIFIER];
    
    if (!cell) {
        cell = [self createCell];
    }
    
    id item = [_boundObjects objectAtIndex:indexPath.row];
    
    // reset the image view (stops transition)
    cell.imageView.image = nil;
    
    cell.dataSource = item;
    
    return cell;
}

@end
