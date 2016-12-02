//
//  DetailViewController.m
//  ImageLoadingAndCaching
//
//  Created by Yankun Jin on 11/28/16.
//  Copyright © 2016 Yankun Jin. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()<UIScrollViewDelegate>

@property (assign, nonatomic) CGFloat ratio;


@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    if (_record) {
        self.detailDescriptionLabel.text = self.record.name;
        [self.imageView setImage:self.record.image];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.ratio = [self calculateRatio];
    [self configureView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma marl - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    int contentOffSetY = scrollView.contentOffset.y;
    int interval = contentOffSetY / self.view.bounds.size.height;
    
    CGFloat offSet = fmod(contentOffSetY, self.view.bounds.size.height);
    
    if (interval % 2 == 0) {
        [self.topLayoutConstrant setConstant:MAX(0, offSet)];
    } else [self.topLayoutConstrant setConstant:MAX(0, self.view.bounds.size.height - offSet)];
    
    //[self.topLayoutConstrant setConstant:MAX(0, scrollView.contentOffset.y) * self.ratio];
}


#pragma mark - Managing the detail item

- (void)setDetailItem:(NSDate *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void) setRecord:(Record *)record {
    if (_record != record) {
        _record = record;
    }
    [self configureView];
    [self calculateRatio];
}

- (CGFloat) calculateRatio {
    NSUInteger numerator = self.view.bounds.size.height- 200;
    NSUInteger den = 4000 - self.view.bounds.size.height;
    
    return (CGFloat)numerator / den;
}

@end
