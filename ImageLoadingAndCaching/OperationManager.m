//
//  OperationManager.m
//  ImageLoadingAndCaching
//
//  Created by Yankun Jin on 11/28/16.
//  Copyright © 2016 Yankun Jin. All rights reserved.
//

#import "OperationManager.h"

@implementation Record

- (instancetype) initWithName:(NSString *)name AndURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.name = name;
        self.url = url;
    }
    return self;
}

@end

@interface DownloadOperation ()

@property (nonatomic, strong) Record *record;
//typedef void (^ComplationHander)();
@end

@implementation DownloadOperation

- (instancetype) initWithRecord:(Record *)record {
    self = [super init];
    if (self) {
        self.record = record;
    }
    return self;
}

- (void) main {
    if (self.cancelled) {
        return;
    }
    
    NSData *imageData = [NSData dataWithContentsOfURL:self.record.url];
    
    if (self.cancelled) return;
    
    if (imageData != nil && imageData.length > 0) {
        UIImage *image = [UIImage imageWithData:imageData];
        self.record.image = image;
        self.record.status = Downloaded;
    } else {
        self.record.status = Failed;
        self.record.image = [UIImage imageNamed:@"failed"];
    }
}

@end

@interface FilterOperation ()

@property (nonatomic, strong) Record *record;
//typedef void (^ComplationHander)();
@end

@implementation FilterOperation

- (instancetype) initWithRecord:(Record *)record {
    self = [super init];
    if (self) {
        self.record = record;
    }
    return self;
}

- (void) main {
    if (self.cancelled) {
        return;
    }
    
    
    
    if (self.cancelled) return;
    
    if (self.record.status != Downloaded || self.record.image == nil) {
        return;
    }
    UIImage *image = [self filterImage:self.record.image];
    
    if (image != nil) {
        self.record.image = image;
        self.record.status = Filtered;
        [OperationManager saveImage:image andName:self.record.name];
    } else {
        
        self.record.status = Failed;
    }
    
}

- (UIImage*) filterImage:(UIImage*) image {
    CIImage *cImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    if (self.cancelled) {
        return nil;
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
    [filter setValue:cImage forKey:kCIInputImageKey];
    [filter setValue:@(0.8) forKey:@"inputIntensity"];
    CIImage *oImage = filter.outputImage;
    
    if (self.cancelled) {
        return nil;
    }
    
    CGImageRef outImage = [context createCGImage:oImage fromRect:oImage.extent];
    
    UIImage *result = [UIImage imageWithCGImage:outImage];
    
    return result;
    
}

@end


@implementation OperationManager

+(OperationManager*)sharedManager {
    static OperationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[OperationManager alloc] init];
    });
    return manager;
}

+ (UIImage*)loadImageWithName:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%@.png", name] ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

+ (void)saveImage: (UIImage*)image
          andName:(NSString*)name
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%@.png", name] ];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.pendingFilterTask = [NSMutableDictionary new];
        self.pendingDownloadingTask = [NSMutableDictionary new];
        
        self.dQueue = [[NSOperationQueue alloc] init];
        self.dQueue.name = @"dQueue";
        [self.dQueue setMaxConcurrentOperationCount:1];
        
        self.fQueue = [[NSOperationQueue alloc] init];
        self.fQueue.name = @"dQueue";
        [self.fQueue setMaxConcurrentOperationCount:1];
        
        
    }
    return self;
}



@end
