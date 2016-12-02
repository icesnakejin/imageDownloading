//
//  OperationManager.h
//  ImageLoadingAndCaching
//
//  Created by Yankun Jin on 11/28/16.
//  Copyright © 2016 Yankun Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum NSUInteger {
    BeforeDownload = 0,
    Downloaded,
    Filtered,
    Failed
    
} Status;


// Model
@interface Record : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSURL *url;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, assign) Status status;

- (instancetype) initWithName:(NSString*)name
                       AndURL:(NSURL*)url;

@end

@interface DownloadOperation : NSOperation

- (instancetype) initWithRecord:(Record*)record;

@end

@interface FilterOperation : NSOperation

- (instancetype) initWithRecord:(Record*)record;

@end

@interface OperationManager : NSObject

@property (nonatomic, strong) NSMutableDictionary<id, NSOperation*> *pendingDownloadingTask;
@property (nonatomic, strong) NSMutableDictionary<id, NSOperation*> *pendingFilterTask;

@property (nonatomic, strong) NSOperationQueue *dQueue;
@property (nonatomic, strong) NSOperationQueue *fQueue;

+(OperationManager*)sharedManager;

+ (void)saveImage: (UIImage*)image
          andName:(NSString*)name;

+(UIImage*)loadImageWithName:(NSString*)name;

@end
