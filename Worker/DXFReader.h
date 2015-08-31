//
//  DXFReader.h
//  Worker
//
//  Created by Matt Andrews on 4/08/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#ifndef __Worker__DXFReader__
#define __Worker__DXFReader__

#define DXF_MAX_LINE_LENGTH 258 

#define DXF_DEFAULT_LAYER "0"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#endif /* defined(__Worker__DXFReader__) */


typedef struct DXFVertex {
    
    double x;
    double y;
    double bulge;
    
} DXFVertex;


typedef struct DXFPolyline{
    
    char      *handle;
    int       closed;
    char      *layer;
    int        vertexCount;
    DXFVertex *vertices;
    
} DXFPolyline;


typedef struct DXFCircle {
    
    DXFVertex centre;
    char     *handle;
    char     *layer;
    double    radius;
    
} DXFCircle;


typedef union DXFGeometry {
    
    DXFCircle   circle;
    DXFPolyline polyline;
    
} DXFGeometry;


typedef enum DXFType {
    
    DXFTypeCircle,
    DXFTypePolyline
    
} DXFType;


typedef struct DXFEntity {
    
    union DXFGeometry geometry;
    int               entityCount;
    struct DXFEntity  *entities;
    struct DXFEntity  *next;          // Enables use as a linked list node
    DXFType           type;
    
} DXFEntity;



typedef struct DXFParts {
    
    int nParts;
    DXFEntity *parts;
    
} DXFParts;


typedef struct DXFBounds {
    
    double xMin;
    double yMin;
    double xMax;
    double yMax;
    
} DXFBounds;


DXFParts *DXFRead(const char *file);
//void DXFFree(DXFNode *head);

