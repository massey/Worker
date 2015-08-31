//
//  MASPolylineTests.m
//  Worker
//
//  Created by Matt Andrews on 27/08/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "MASPolyline.h"
#import "MASGeometry.h"

@interface MASPolylineTests : XCTestCase

@end

@implementation MASPolylineTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testOffsetCoords {
    MASPolyline *polyline = [[MASPolyline alloc] init];
    
    [polyline addVertexWithCoords:10.0 y:10.0];
    [polyline addVertexWithCoords:40.0 y:10.0];
    [polyline addVertexWithCoords:40.0 y:30.0];
    [polyline addVertexWithCoords:10.0 y:30.0];
    
    MASPolyline *offset = [MASPolyline offset:polyline distance:5.0];
    
    MASPoint *testPoint1 = [offset vertices][0];
    MASPoint *testPoint2 = [offset vertices][2];
    
    XCTAssertEqual(testPoint1.x, 5.0, @"Offset wrong");
    XCTAssertEqualWithAccuracy(testPoint1.y, 5.0, 0.000001, @"offset wrong");
    XCTAssertEqualWithAccuracy(testPoint2.x, 45.0, 0.000001, @"offset wrong");
    XCTAssertEqualWithAccuracy(testPoint2.y, 35.0, 0.000001, @"offset wrong");
}

- (void)testOffsetCoordsWithBulgeFactors {
    MASPolyline *polyline = [[MASPolyline alloc] init];
    
    [polyline addVertexWithCoords:10.0 y:20.0];
    [polyline addVertexWithCoordsAndBulge:10.0 y:10.0 bulge:1.0];
    [polyline addVertexWithCoords:20.0 y:10.0];
    [polyline addVertexWithCoordsAndBulge:20.0 y:30.0 bulge:1.0];
    [polyline addVertexWithCoords:10.0 y:30.0];
    
    MASPolyline *offset = [MASPolyline offset:polyline distance:5.0];
    
    MASPoint *testPoint1 = [offset vertices][0];
    MASPoint *testPoint2 = [offset vertices][1];
    MASPoint *testPoint3 = [offset vertices][3];
    
    XCTAssertEqual(testPoint1.x, 5.0, @"Offset wrong");
    XCTAssertEqualWithAccuracy(testPoint2.x, 5.0, 0.000001, @"offset wrong");
    XCTAssertEqualWithAccuracy(testPoint2.y, 10.0, 0.000001, @"offset wrong");
    XCTAssertEqualWithAccuracy(testPoint3.x, 25.0, 0.000001, @"offset wrong");
    XCTAssertEqualWithAccuracy(testPoint3.y, 30.0, 0.000001, @"offset wrong");
}


@end
