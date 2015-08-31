//
//  MASPolyline.h
//  Worker
//
//  Created by Matt Andrews on 7/08/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXFReader.h"

@class MASPoint;

@interface MASPolyline : NSObject

@property NSMutableArray *vertices;
@property BOOL closed;

+ (MASPolyline*)offset:(MASPolyline*)polyline distance:(double)distance;

- (id)initWithArray:(NSArray*)array;
- (id)initWithDXFPolyline:(DXFPolyline*)polyline;

- (void)addVertex:(MASPoint*)vertex;
- (void)addVertexWithCoords:(double)x y:(double)y;
- (void)addVertexWithCoordsAndBulge:(double)x y:(double)y bulge:(double)bulge;;

- (NSNumber*)areaSquareMetres;
- (NSNumber*)areaSquareMillimetres;

// Return the centre point of bounding rectangle
- (MASPoint *)centre;

- (NSNumber*)perimeterMetres;
- (NSNumber*)perimeterMillimetres;

// Return bounds as an object with keys 'xMin', 'yMin', 'xMax', 'yMax'
- (NSDictionary*)bounds;

// Returns 1 for interior points and 0 for exterior
- (BOOL)containsPoint:(MASPoint*)point;

- (NSString*)DXFString;

@end
