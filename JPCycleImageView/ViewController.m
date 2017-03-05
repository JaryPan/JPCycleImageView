//
//  ViewController.m
//  JPCycleImageView
//
//  Created by ovopark_iOS on 16/8/9.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import "ViewController.h"
#import "JPCycleImageView.h"

@interface ViewController () <JPCycleImageViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    JPCycleImageView *cycleImageView = [[JPCycleImageView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width*9/16)];
    cycleImageView.dataSource = @[@"http://pic1a.nipic.com/2008-10-23/20081023151650958_2.jpg",
                                  @"http://img6.faloo.com/Picture/0x0/0/170/170930.jpg",
                                  @"http://imgstore.cdn.sogou.com/app/a/100540002/714860.jpg",
                                  @"http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1402/13/c4/31220076_1392274799959_800x600.jpg"];
    cycleImageView.showActivityIndicator = YES;
    cycleImageView.backgroundColor = [UIColor grayColor];
    cycleImageView.delegate = self;
    [self.view addSubview:cycleImageView];
    
    [cycleImageView reloadData];
}

#pragma mark - JPCycleImageViewDelegate
- (void)cycleImageView:(JPCycleImageView *)cycleImageView didClickImage:(UIImage *)image atIndex:(NSInteger)index
{
    NSLog(@"clickedImageAtIndex:%ld", index);
}
- (void)cycleImageView:(JPCycleImageView *)cycleImageView didScrollToIndex:(NSInteger)newIndex fromIndex:(NSInteger)oldIndex
{
    NSLog(@"newIndex:%ld, oldIndex:%ld", newIndex, oldIndex);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
