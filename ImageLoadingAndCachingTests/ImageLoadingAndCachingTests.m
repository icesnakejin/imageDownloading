//
//  ImageLoadingAndCachingTests.m
//  ImageLoadingAndCachingTests
//
//  Created by Yankun Jin on 11/28/16.
//  Copyright © 2016 Yankun Jin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MasterViewModel.h"

@interface ImageLoadingAndCachingTests : XCTestCase
@property (strong, nonatomic) MasterViewModel *vModel;
@end

@implementation ImageLoadingAndCachingTests

- (void)setUp {
    [super setUp];
    self.vModel = [[MasterViewModel alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void) testFetchingPhotoList {
    XCTestExpectation* expectation = [self expectationWithDescription:@"HTTP request"];
    [self.vModel fetchPhotoDataDetailWithCompletion:^{
        XCTAssertLessThan(self.vModel.photos.count, 0, @"photos not fetched");
        //NSAssert(self.vModel.photos && self.vModel.photos.count > 0, @"photos not fetched");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

@end
