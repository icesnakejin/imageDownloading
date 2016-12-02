//
//  MasterViewModel.m
//  ImageLoadingAndCaching
//
//  Created by Yankun Jin on 11/28/16.
//  Copyright © 2016 Yankun Jin. All rights reserved.
//

#import "MasterViewModel.h"
#import "OperationManager.h"

static NSString *urlString = @"https://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist";

@interface MasterViewModel ()

@property (nonatomic, assign) NSUInteger count;

@end

@implementation MasterViewModel

- (instancetype) init {
    self = [super init];
    if (self) {
        self.manager = [[OperationManager alloc] init];
        self.photos = [NSMutableArray new];
    }
    return self;
}

- (void) fetchPhotoDataDetailWithCompletion:(void(^)()) compleyionHandler {
    NSURL *fetchingURL = [NSURL URLWithString:urlString];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:fetchingURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *jsonError = nil;
        NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:&jsonError];
        if (jsonError == nil) {
            [dict enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
                Record *record = [[Record alloc] initWithName:key AndURL:[NSURL URLWithString:obj]];
                [self.photos addObject:record];
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (compleyionHandler) {
                compleyionHandler();
            }
        });
    }];
    [dataTask resume];
}

#pragma -mark UITableViewCell/Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell"];
    if (cell == nil) {
        _count ++;
        NSLog(@"total number of created cell: %lu", (unsigned long)_count);
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"photoCell"];
    }
//    NSLog(@"reused cell address : %@", cell);
//    NSLog(@"reused cell indexPath : %@", indexPath);
    
    Record *record = self.photos[indexPath.row];
    
    [cell.textLabel setText:record.name];
    [cell.imageView setImage:[OperationManager loadImageWithName:record.name]];
    
    if (cell.imageView.image) {
        return cell;
    }
    
    
    NSLog(@"reused cell address : %@", cell);
    //NSLog(@"reused cell indexPath : %@", indexPath);
    
    switch (record.status) {
        case Filtered:
            //NSLog(@"%@", @"Whole process complete");
            break;
        case Failed:
            [cell.textLabel setText:@"Failed process"];
            break;
//        case BeforeDownload:
//            if (!tableView.dragging && !tableView.decelerating) {
//                [self startDownloadingProcess:record atIndexPath:indexPath];
//            }
//            
//            break;
//        case Downloaded:
//             if (!tableView.dragging && !tableView.decelerating) {
//                 [self startFilteringProcess:record atIndexPath:indexPath];
//             }
//            break;
            
        case BeforeDownload:
        //case Downloaded:
            if (!tableView.dragging && !tableView.decelerating) {
                [self startBothProcess:record atIndexPath:indexPath];
            }
            
            break;
        default:
            break;
    }
    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photos.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Record *record = self.photos[indexPath.row];
    [self.detailViewController setRecord:record];
    [self.splitViewController showDetailViewController:self.detailViewController sender:self];
}



#pragma -mark scrollView Delegate

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self suspendAll];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self startOrCancelOperations];
    [self resumeAll];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self startOrCancelOperations];
        [self resumeAll];
    }
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (!scrollView.isDecelerating) {
        [self startOrCancelOperations];
        [self resumeAll];
    }
}

- (void) startProcessing:(Record*) record
             atIndexPath:(NSIndexPath*) indexPath{
    if (record.status == BeforeDownload) {
        [self startDownloadingProcess:record atIndexPath:indexPath];
    }
    
    if (record.status == Downloaded) {
        [self startFilteringProcess:record atIndexPath:indexPath];
    }
}

- (void)startOrCancelOperations {
    NSMutableSet *allPendingOperations = [NSMutableSet setWithArray:[[self.manager pendingDownloadingTask] allKeys]];
    [allPendingOperations unionSet:[NSSet setWithArray:[[self.manager pendingDownloadingTask] allKeys]]];
    
    NSSet *visibleSet = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    // get Operaions to Cancel
    NSMutableSet *toCancel = allPendingOperations;
    [toCancel minusSet:visibleSet];
    
    // get Operations to Start
    NSMutableSet *toStart = [NSMutableSet setWithSet:visibleSet];
    [toStart minusSet:allPendingOperations];
    
    [toCancel enumerateObjectsUsingBlock:^(NSIndexPath *  _Nonnull obj, BOOL * _Nonnull stop) {
        if (self.manager.pendingDownloadingTask[obj] != nil) {
            [self.manager.pendingDownloadingTask[obj] cancel];
        }
        [self.manager.pendingDownloadingTask removeObjectForKey:obj];
        
        if (self.manager.pendingFilterTask[obj] != nil) {
            [self.manager.pendingFilterTask[obj] cancel];
        }
        [self.manager.pendingFilterTask removeObjectForKey:obj];

    }];
    
    [toStart enumerateObjectsUsingBlock:^(NSIndexPath *  _Nonnull obj, BOOL * _Nonnull stop) {
        Record *record = [self.photos objectAtIndex:obj.row];
        if (record.status == BeforeDownload) {
            //[self startDownloadingProcess:record atIndexPath:obj];
             [self startBothProcess:record atIndexPath:obj];
        }
        
        if (record.status == Downloaded) {
            [self startDownloadingProcess:record atIndexPath:obj];
        }
    }];
}

- (void) suspendAll {
    [self.manager.dQueue setSuspended:YES];
    [self.manager.fQueue setSuspended:YES];
}

- (void) resumeAll {
    [self.manager.dQueue setSuspended:NO];
    [self.manager.fQueue setSuspended:NO];
}



// start Downloading Process
- (void) startDownloadingProcess:(Record *)record atIndexPath:(NSIndexPath*) indexPath{
    if ([[self.manager.pendingDownloadingTask allKeys] containsObject:indexPath]) {
        return;
    }
    
    DownloadOperation *dOperation = [[DownloadOperation alloc] initWithRecord:record];
    __weak DownloadOperation *weakOperation = dOperation;
    dOperation.completionBlock = ^(){
        if (weakOperation.cancelled) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.manager.pendingDownloadingTask removeObjectForKey:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
       
    };
    self.manager.pendingDownloadingTask[indexPath] = dOperation;
    [self.manager.dQueue addOperation:dOperation];
}

// start filtering process
- (void) startFilteringProcess:(Record *)record atIndexPath:(NSIndexPath*) indexPath{
    if ([[self.manager.pendingFilterTask allKeys] containsObject:indexPath]) {
        return;
    }
    
    FilterOperation *fOperation = [[FilterOperation alloc] initWithRecord:record];
    __weak FilterOperation *weakOperation = fOperation;
    fOperation.completionBlock = ^(){
        if (weakOperation.cancelled) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.manager.pendingFilterTask removeObjectForKey:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
    };
    self.manager.pendingFilterTask[indexPath] = fOperation;
    [self.manager.fQueue addOperation:fOperation];
}

// start Both process with dependency
- (void) startBothProcess:(Record *)record atIndexPath:(NSIndexPath*) indexPath{
    if ([[self.manager.pendingDownloadingTask allKeys] containsObject:indexPath]) {
        return;
    }
    
    DownloadOperation *dOperation = [[DownloadOperation alloc] initWithRecord:record];
    __weak DownloadOperation *weakOperation = dOperation;
    dOperation.completionBlock = ^(){
        if (weakOperation.cancelled) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.manager.pendingDownloadingTask removeObjectForKey:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
        
    };
    self.manager.pendingDownloadingTask[indexPath] = dOperation;
    [self.manager.dQueue addOperation:dOperation];
    
    FilterOperation *fOperation = [[FilterOperation alloc] initWithRecord:record];
    __weak FilterOperation *weakfOperation = fOperation;
    weakfOperation.completionBlock = ^(){
        if (weakOperation.cancelled) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
    };
    [self.manager.dQueue addOperation:fOperation];
    [fOperation addDependency:dOperation];
}

@end
