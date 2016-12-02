//
//  MasterViewModel.h
//  ImageLoadingAndCaching
//
//  Created by Yankun Jin on 11/28/16.
//  Copyright © 2016 Yankun Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OperationManager.h"
#import "DetailViewController.h"

@interface MasterViewModel : NSObject<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) DetailViewController *detailViewController;
@property (nonatomic, strong) UISplitViewController *splitViewController;
@property (nonatomic) void (^configCell) (UITableViewCell *cell, id  object);
@property (nonatomic) OperationManager *manager;

- (void) fetchPhotoDataDetailWithCompletion:(void(^)()) compleyionHandler;

@end
