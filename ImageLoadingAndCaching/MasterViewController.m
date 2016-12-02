//
//  MasterViewController.m
//  ImageLoadingAndCaching
//
//  Created by Yankun Jin on 11/28/16.
//  Copyright © 2016 Yankun Jin. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "MasterViewModel.h"

@interface MasterViewController ()


@property NSMutableArray *objects;
@property(nonatomic, strong) MasterViewModel *dataSource;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[self.splitViewController.viewControllers lastObject] ;
    self.dataSource = [[MasterViewModel alloc] init];
    self.dataSource.tableView = self.tableView;
    self.dataSource.detailViewController = self.detailViewController;
    self.dataSource.splitViewController = self.splitViewController;
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
    [self.dataSource fetchPhotoDataDetailWithCompletion:^{
        [self.tableView reloadData];
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
