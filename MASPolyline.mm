 //
//  MASPolyline.m
//  Worker
//
//  Created by Matt Andrews on 7/08/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#import "MASPolyline.h"
#import "MASGeometry.h"
#import "MASEntity.h"
#import "MASVector.h"

@implementation MASPolyline

+ (MASPolyline*)offset:(MASPolyline*)polyline distance:(double)distance
{
    MASPolyline* offset = [[MASPolyline alloc] init];
    
    MASPoint *prev, *current, *next, *newVertex;
    MASVector prevV, nextV, unitDir;
    double angle, displacement, rotAngle;
    
    int count = (int)[[polyline vertices] count];
    
    for (int h = count - 1, i = 0, j = 1; i < count; i++) {
        prev    = [polyline vertices][h];
        current = [polyline vertices][i];
        next    = [polyline vertices][j];
        
        prevV.x = (current.x - prev.x);
        prevV.y = (current.y - prev.y);
        nextV.x = (next.x - current.x);
        nextV.y = (next.y - current.y);
        
        MASVector prevVUnit = *prevV.unit();
        MASVector nextVUnit = *nextV.unit();
    
        if (current.bulge != 0.0 || prev.bulge != 0.0) {
            displacement = distance;
            unitDir = nextVUnit;
            rotAngle = (M_PI - 4 * atan(current.bulge)) / 2;
            
            if (current.bulge > 0.0) {
                unitDir.rotate(rotAngle + M_PI);
            } else if (current.bulge < 0.0) {
                unitDir.rotate(-rotAngle);
            } else if (current.bulge == 0.0 && prev.bulge > 0.0) {
                unitDir.rotate(-rotAngle);
            } else if (current.bulge == 0.0 && prev.bulge < 0.0) {
                unitDir.rotate(rotAngle + M_PI);
            }
            
            unitDir * displacement;
            
            newVertex = [[MASPoint alloc] init];
            newVertex.x = current.x + unitDir.x;
            newVertex.y = current.y + unitDir.y;
            newVertex.bulge = current.bulge;
            
            [offset addVertex:newVertex];
            
        } else {
            if (turnType(prev, current, next) > 0) {
                angle = MASVector::angle(prevVUnit, nextVUnit);
                displacement = distance / sin(angle / 2);
                
                prevVUnit - nextVUnit;
                unitDir = *prevVUnit.unit();
                
                unitDir * displacement;
                
            } else if (turnType(prev, current, next) < 0) {
                angle = MASVector::angle(prevVUnit, nextVUnit);
                displacement = distance / sin(angle / 2);
                
                nextVUnit - prevVUnit;
                unitDir = *nextVUnit.unit();
                
                unitDir * displacement;
                
            } else if (turnType(prev, current, next) == 0) {
                displacement = distance;
                unitDir = nextVUnit;
                unitDir.rotate(-M_PI / 2);
                
                unitDir * displacement;
            }
            
            newVertex = [[MASPoint alloc] init];
            newVertex.x = current.x + unitDir.x;
            newVertex.y = current.y + unitDir.y;
            newVertex.bulge = 0.0;
            
            [offset addVertex:newVertex];
        }
        
        h = (h + 1) % count;
        j = (j + 1) % count;
    }
    
    return offset;
}


- (id)init
{
    self = [super init];
    if (self) {
        
        _vertices = [[NSMutableArray alloc] init];
        _closed = 0;
        
    }
    return self;
}


- (id)initWithArray:(NSArray*)array
{
    self = [super init];
    if (self) {
        
        NSUInteger count = [array count];
        
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++) {
            
            result[i] = [[MASPoint alloc] initWithObject:array[i]];
            
        }
        
        _vertices = result;
        
    }
    return self;
}


- (id)initWithDXFPolyline:(DXFPolyline*)polyline
{
    
    
    self = [super init];
    if (self) {
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < polyline->vertexCount; i++) {
            [result addObject:[[MASPoint alloc] initWithDXFVertex:&polyline->vertices[i]]];

        }
        
        _vertices = [[NSMutableArray alloc] initWithArray:result];
        _closed = polyline->closed;
        
    }
    
    return self;
    
}


- (void)addVertex:(MASPoint*)vertex
{
    [_vertices addObject:vertex];
}


- (void)addVertexWithCoords:(double)x y:(double)y
{
    MASPoint *newVertex = [[MASPoint alloc] init];
    newVertex.x = x;
    newVertex.y = y;
    newVertex.bulge = 0.0;
    
    [_vertices addObject:newVertex];
}


- (void)addVertexWithCoordsAndBulge:(double)x y:(double)y bulge:(double)bulge
{
    MASPoint *newVertex = [[MASPoint alloc] init];
    newVertex.x = x;
    newVertex.y = y;
    newVertex.bulge = bulge;
    
    [_vertices addObject:newVertex];
}


- (NSNumber*)areaSquareMetres
{
    
    return [NSNumber numberWithDouble:[[self areaSquareMillimetres] doubleValue] / 1000000];
    
}


- (NSNumber*)areaSquareMillimetres
{
    double sum = 0.0, xi, xj, yi, yj;
    
    NSUInteger count = [_vertices count];
    
    for (int i = 0, j = 1; i < count; j = (++i + 1) % count) {
        
        xi = [_vertices[i] x];
        yi = [_vertices[i] y];
        xj = [_vertices[j] x];
        yj = [_vertices[j] y];
        
        sum += (xi * yj) - (xj * yi);
        
    }
    
    sum /= 2;
    
    return [NSNumber numberWithDouble:sum];
    
}


// Return perimeter in millimetres
- (NSNumber*)perimeterMillimetres
{
    double sum = 0.0, xi, xj, yi, yj;
    
    NSUInteger count = [_vertices count];
    
    for (int i = 0, j = 1; i < count; j = (++i + 1) % count) {
        
        xi = [_vertices[i] x];
        yi = [_vertices[i] y];
        xj = [_vertices[j] x];
        yj = [_vertices[j] y];
        
        sum += sqrt(pow((xj - xi), 2) + pow((yj - yi), 2));
        
    }
    
    return [NSNumber numberWithDouble:sum];
}


- (NSNumber*)perimeterMetres
{
    return [NSNumber numberWithDouble:[[self perimeterMillimetres] doubleValue] / 1000];
}


- (NSDictionary*)bounds
{
    NSMutableDictionary *bounds = [[NSMutableDictionary alloc] init];
    
    double xMin = INFINITY;
    double yMin = INFINITY;
    double xMax = -INFINITY;
    double yMax = -INFINITY;
    
    NSUInteger count = [[self vertices] count];
    
    for (int i = 0; i < count; i++) {
        
        if ([(MASPoint*)[self vertices][i] x] < xMin) {
            xMin = [(MASPoint*)[self vertices][i] x];
        }
        if ([(MASPoint*)[self vertices][i] y] < yMin) {
            yMin = [(MASPoint*)[self vertices][i] y];
        }
        if ([(MASPoint*)[self vertices][i] x] > xMax) {
            xMax = [(MASPoint*)[self vertices][i] x];
        }
        if ([(MASPoint*)[self vertices][i] y] > yMax) {
            yMax = [(MASPoint*)[self vertices][i] y];
        }
        
    }
    
    [bounds setObject:[NSNumber numberWithDouble:xMin] forKey:@"xMin"];
    [bounds setObject:[NSNumber numberWithDouble:yMin] forKey:@"yMin"];
    [bounds setObject:[NSNumber numberWithDouble:xMax] forKey:@"xMax"];
    [bounds setObject:[NSNumber numberWithDouble:yMax] forKey:@"yMax"];
    
    return bounds;
    
}


- (MASPoint*)centre
{
    MASPoint *centre = [[MASPoint alloc] init];
    
    int x, y;
    
    x = [[self bounds][@"xMin"] intValue] + [[self bounds][@"xMax"] intValue];
    x /= 2;
    
    y = [[self bounds][@"yMin"] intValue] + [[self bounds][@"yMax"] intValue];
    y /= 2;
    
    [centre setX:x];
    [centre setY:y];
    
    return centre;
}


- (BOOL)containsPoint:(MASPoint*)point
{
    unsigned long int count = [[self vertices] count], i, j;
    int c = 0;
    
    for (i = 0, j = count - 1; i < count; j = i++) {
        if (((([[self vertices][i] y] <= [point y]) && ([point y] < [[self vertices][j] y])) ||
             (([[self vertices][j] y] <= [point y]) && ([point y] < [[self vertices][i] y]))) &&
            ([point x] < ([[self vertices][j] x] - [[self vertices][i] x]) * ([point y] - [[self vertices][i] y]) / ([[self vertices][j] y] - [[self vertices][i] y]) + [[self vertices][i] x]))
            c = !c;
    }
    
    return c;
}


- (NSString*)DXFString
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    [string appendString:[MASEntity DXFPairString:@90 value:[NSString stringWithFormat:@"%lu", (unsigned long)[_vertices count]]]];
    [string appendString:[MASEntity DXFPairString:@70 value:[NSString stringWithFormat:@"%d", _closed]]];
    
    for (int i = 0; i < [_vertices count]; i++) {
        
        [string appendString:[_vertices[i] DXFString]];
        
    }
    
    return [NSString stringWithString:string];
}


// Helpers


// If turntype is CCW return 1 else return 0
int turnType(MASPoint *a, MASPoint *b, MASPoint *c)
{
    double sum = 0.0;
    
    sum += (a.x * b.y) - (b.x * a.y);
    sum += (b.x * c.y) - (c.x * b.y);
    sum += (c.x * a.y) - (a.x * c.y);
    
    if ((sum /= 2) > 0) {
        return 1;
    }
    
    return 0;
}

@end
