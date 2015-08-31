//
//  DXFReader.c
//  Worker
//
//  Created by Matt Andrews on 4/08/2015.
//  Copyright (c) 2015 Massey. All rights reserved.
//

#include "DXFReader.h"
#include <math.h>

#define EPSILON 0.0001

typedef struct pair {
    int groupCode;
    char value[DXF_MAX_LINE_LENGTH];
} pair;


void DXFReadLine(pair *pair, FILE *fp);
DXFPolyline DXFReadPolyline(pair *pair, FILE *fp);
DXFCircle DXFReadCircle(pair *pair, FILE *fp);
DXFVertex DXFReadVertex(pair *pair, FILE *fp);

void DXFBuildParts(DXFEntity *parts, int nParts, DXFEntity *entitities, int nEntities);
int DXFSortByLowerBounds(const void *obj1, const void *obj2);
int DXFSortByCentreY(const void *obj1, const void *obj2);
DXFBounds DXFPolylineBounds(DXFPolyline *polyline);
DXFVertex DXFPolylineCentre(DXFPolyline *polyline);
void DXFArrayToList(DXFEntity *array, int nel);
int DXFPointInPolygon(DXFPolyline *polyline, DXFVertex *point);

void DXFzero(DXFEntity *entity);
void DXFmoveEntity(DXFEntity *entity, DXFVertex *vector);
void DXFmovePolyline(DXFPolyline *polyline, DXFVertex *vector);
void DXFmoveCircle(DXFCircle *circle, DXFVertex *vector);
void DXFmoveVertex(DXFVertex *vertex, DXFVertex *vector);

double DXFPolylineArea(DXFPolyline* polyline);
double DXFTriangleArea(DXFVertex *a, DXFVertex *b, DXFVertex *c);
void DXFReversePolyline(DXFPolyline *polyline);
DXFVertex DXFbasePoint(DXFPolyline *polyline);





// Return head node from entity list
DXFParts *DXFRead(const char *file)
{
   
    DXFEntity *entities = malloc(sizeof(DXFEntity) * 1000);
    DXFEntity *parts = malloc(sizeof(DXFEntity) * 100);
    
    int entityCount = 0;
    int partCount = 0;
    
    int entityArrayLength = 1000;
    int partArrayLength = 100;
    

    FILE *fp;
    if ((fp = fopen(file, "r")) == NULL) {
        fprintf(stderr, "DXFRead failed to open file.");
    }
    
    pair pair;
    char section[16];
    
    union DXFGeometry new;
    
    DXFReadLine(&pair, fp);
    
    while (strcmp(pair.value, "EOF") != 0) {
        if (pair.groupCode == 0) {
            
            // Keep track of current section
            if (strcmp(pair.value, "SECTION") == 0) {
                DXFReadLine(&pair, fp);
                sscanf(pair.value, "%s", section);
            }
            
            if (strcmp(pair.value, "LWPOLYLINE") == 0 && strcmp(section, "ENTITIES") == 0) {
                new.polyline = DXFReadPolyline(&pair, fp);
                
                if (strncmp(new.polyline.layer, "P", 1) == 0) {
                    if (partArrayLength == partCount) {
                        parts = realloc(parts, 2 * partArrayLength * sizeof(DXFEntity));
                        partArrayLength *= 2;
                    }
                    
                    parts[partCount].geometry = new;
                    parts[partCount].type = DXFTypePolyline;
                    parts[partCount].entities = NULL;
                    partCount++;
                    
                } else {
                    if (entityArrayLength == entityCount) {
                        entities = realloc(entities, 2 * entityArrayLength * sizeof(DXFEntity));
                        entityArrayLength *= 2;
                    }
                    
                    entities[entityCount].geometry = new;
                    entities[entityCount].type = DXFTypePolyline;
                    entities[entityCount].entityCount = 0;
                    entityCount++;

                }
                
                continue;
                
            } else if (strcmp(pair.value, "CIRCLE") == 0 && strcmp(section, "ENTITIES") == 0) {
                new.circle = DXFReadCircle(&pair, fp);
                
                if (entityArrayLength == entityCount) {
                    entities = realloc(entities, 2 * entityArrayLength * sizeof(DXFEntity));
                    entityArrayLength *= 2;
                }
                
                entities[entityCount].geometry = new;
                entities[entityCount].type = DXFTypeCircle;
                entities[entityCount].entityCount = 0;
                entityCount++;
                
                continue;
            }
        }
        
        DXFReadLine(&pair, fp);
    }
    
    fclose(fp);
    
    // Sort Parts by lower bounds and entities by centre y coordinate
    qsort(parts, partCount, sizeof(DXFEntity), DXFSortByLowerBounds);
    qsort(entities, entityCount, sizeof(DXFEntity), DXFSortByCentreY);
    
    DXFArrayToList(entities, entityCount);
    
    DXFBuildParts(parts, partCount, entities, entityCount);
    
    DXFParts *result = malloc(sizeof(DXFParts*));
    result->nParts = partCount;
    result->parts = parts;
    
    return result;
}


void DXFBuildParts(DXFEntity *parts, int nParts, DXFEntity *entities, int nEntities)
{
    DXFEntity *entry = entities;
    DXFEntity **last = &entities;
    
    DXFVertex centre;
    double upperBounds;
    
    for (int i = 0; i < nParts; i++) {
        
        parts[i].entities = malloc(4 * sizeof(DXFEntity));
        parts[i].entityCount = 0;
        int arrayLength = 4;
        
        // Set entry to beginning of list
        entry = entities;
        last = &entities;
        
        // Traverse entities array like linked list
        while (entry != NULL) {
            // Get centre point from different entity types
            if (entry->type == DXFTypePolyline) {
                centre = DXFPolylineCentre(&entry->geometry.polyline);
            } else if (entry->type == DXFTypeCircle) {
                centre = entry->geometry.circle.centre;
            }
            
            // Break loop if entity centrepoint is above current part's
            // upper bounds
            upperBounds = DXFPolylineBounds(&parts[i].geometry.polyline).yMax;
            
            if (centre.y > (upperBounds + 1000)) {
                break;
            }
            
            // Double array size if needs be
            if (arrayLength == parts[i].entityCount) {
                parts[i].entities = realloc(parts[i].entities, 2 * arrayLength * sizeof(DXFEntity));
                arrayLength *= 2;
            }
            
            // Check if centre point is internal to part
            if (DXFPointInPolygon(&parts[i].geometry.polyline, &centre)) {
                
                // Add entity to part's entities array
                parts[i].entities[parts[i].entityCount] = *entry;
                parts[i].entityCount++;
                
                // Remove current entity from main entities list
                *last = entry->next;
            }
            
            last = &entry->next;
            entry = entry->next;
            
        }
        
        DXFzero(&parts[i]);
    }
}


// Return 1 for interior points or on boundary, 0 for exterior
int DXFPointInPolygon(DXFPolyline *polyline, DXFVertex *point)
{
    int count = polyline->vertexCount;
    
    // If a point is on polygon, return 1
    int i, j;
    for (int i = 0, j = 1; i < count; j = (++i + 1) % count) {
        DXFVertex *a, *b, *c;
        a = &polyline->vertices[i];
        b = &polyline->vertices[j];
        c = point;
        
        if (fabs(DXFTriangleArea(a, b, c)) < EPSILON ) {
            return 1;
        }
    }
    
    
    double xPoly[count];
    double yPoly[count];
    
    for (int i = 0; i < count; i++) {
        xPoly[i] = polyline->vertices[i].x;
        yPoly[i] = polyline->vertices[i].y;
    }
    
    double x = point->x;
    double y = point->y;
    
    double slope, xIntersect;
    
    int c = 0;
    for (i = 0, j = count - 1; i < count; j = i++) {
        if (  ((yPoly[i] <= y) && (yPoly[j] > y))  ||  ((yPoly[i] > y) && (yPoly[j] <= y))  ) {
            slope = (yPoly[i] - yPoly[j]) / (xPoly[i] - xPoly[j]);
            xIntersect = (y - yPoly[j]) / slope + xPoly[j];
            
            if (x < xIntersect) {
                c = !c;
                
            }
        }
    }
    
    return c;
}


void DXFArrayToList(DXFEntity *array, int nel)
{
    for (int i = 0; i < nel; i++) {
        if (i == (nel - 1)) {
            array[i].next = NULL;
        } else {
            array[i].next = &array[i + 1];
        }
    }
}


int DXFSortByLowerBounds(const void *obj1, const void *obj2)
{
    DXFEntity *node1 = (DXFEntity*)obj1;
    DXFEntity *node2 = (DXFEntity*)obj2;
    
    int lowerBound1 = DXFPolylineBounds(&node1->geometry.polyline).yMin;
    int lowerBound2 = DXFPolylineBounds(&node2->geometry.polyline).yMin;
    
    if (lowerBound1 < lowerBound2) {
        return -1;
    } else if (lowerBound1 > lowerBound2) {
        return 1;
    }
    
    return 0;
}


int DXFSortByCentreY(const void *obj1, const void *obj2)
{
    DXFEntity *node1 = (DXFEntity*)obj1;
    DXFEntity *node2 = (DXFEntity*)obj2;
    
    int centreY1, centreY2;
    
    if (node1->type == DXFTypePolyline) {
        centreY1 = DXFPolylineCentre(&node1->geometry.polyline).y;
    } else if (node1->type == DXFTypeCircle) {
        centreY1 = node1->geometry.circle.centre.y;
    }
    
    if (node2->type == DXFTypePolyline) {
        centreY2 = DXFPolylineCentre(&node2->geometry.
                                     polyline).y;
    } else if (node2->type == DXFTypeCircle) {
        centreY2 = node2->geometry.circle.centre.y;
    }
    
    if (centreY1 < centreY2) {
        return -1;
    } else if (centreY1 > centreY2) {
        return 1;
    }
    
    return 0;
}


DXFBounds DXFPolylineBounds(DXFPolyline *polyline)
{
    DXFBounds bounds;
    
    double xMin, yMin, xMax, yMax;
    xMin = yMin = INFINITY;
    xMax = yMax = -INFINITY;
    
    int vertexCount = polyline->vertexCount;
    DXFVertex *vertices = polyline->vertices;
    
    for (int i = 0; i < vertexCount; i++) {
        
        if (vertices[i].x < xMin) {
            xMin = vertices[i].x;
        }
        if(vertices[i].y < yMin) {
            yMin = vertices[i].y;
        }
        if (vertices[i].x > xMax) {
            xMax = vertices[i].x;
        }
        if (vertices[i].y > yMax) {
            yMax = vertices[i].y;
        }
    }
    
    bounds.xMin = xMin;
    bounds.yMin = yMin;
    bounds.xMax = xMax;
    bounds.yMax = yMax;
    
    return bounds;
}


DXFVertex DXFPolylineCentre(DXFPolyline *polyline)
{
    DXFVertex centre;
    DXFBounds bounds = DXFPolylineBounds(polyline);
    
    centre.x = (bounds.xMax + bounds.xMin) / 2;
    centre.y = (bounds.yMax + bounds.yMin) / 2;
    
    return centre;
}


void DXFReadLine(pair *pair, FILE *fp)
{
    char line[DXF_MAX_LINE_LENGTH];
    
    if ((fgets(line, DXF_MAX_LINE_LENGTH, fp)) == NULL) {
        fprintf(stderr, "DXFReadLine reached end of file.");
        return;
    };
    sscanf(line, "%i", &pair->groupCode);
    
    
    if ((fgets(line, DXF_MAX_LINE_LENGTH, fp)) == NULL) {
        fprintf(stderr, "DXFReadLine reached end of file.");
        return;
    };
    sscanf(line, "%s", pair->value);
}


DXFVertex DXFReadVertex(pair *pair, FILE *fp)
{
    DXFVertex vertex;
    
    if (pair->groupCode == 10) {
        
        vertex.x = atof(pair->value);
        DXFReadLine(pair, fp);
        
    }
    
    if (pair->groupCode == 20) {
        
        vertex.y = atof(pair->value);
        DXFReadLine(pair, fp);
        
    }
    
    if (pair->groupCode == 30) {

        DXFReadLine(pair, fp);
        
    }
    
    vertex.bulge = 0.0;
    
    if (pair->groupCode == 42) {
        
        vertex.bulge = atof(pair->value);
        DXFReadLine(pair, fp);
        
    }
    
    return vertex;
}


DXFPolyline DXFReadPolyline(pair *pair, FILE *fp)
{
    DXFPolyline polyline;
    DXFVertex vertex;
    
    int vertexCount = 0;
    
    DXFReadLine(pair, fp);
    
    while (pair->groupCode != 0) {
            
        if (pair->groupCode == 5) {
            polyline.handle = strdup(pair->value);
            
        }else if (pair->groupCode == 70) {
            //Layer string needs to be freed.
            polyline.closed = atoi(pair->value);
            
        } else if (pair->groupCode == 8) {
            //Layer string needs to be freed.
            polyline.layer = strdup(pair->value);
                
        } else if (pair->groupCode == 90) {
            polyline.vertices = malloc(atoi(pair->value) * sizeof(DXFVertex));
            polyline.vertexCount = atoi(pair->value);
            
        } else if (pair->groupCode == 10) {
            vertex = DXFReadVertex(pair, fp);
            
            polyline.vertices[vertexCount].x = vertex.x;
            polyline.vertices[vertexCount].y = vertex.y;
            polyline.vertices[vertexCount].bulge = vertex.bulge;
            
            vertexCount++;
            
            continue;
            
        }
        
        DXFReadLine(pair, fp);
        
    }
    
    return polyline;
}


DXFCircle DXFReadCircle(pair *pair, FILE *fp)
{
    DXFCircle circle;
    
    DXFReadLine(pair, fp);
    
    while (pair->groupCode != 0) {
        
        if (pair->groupCode == 5) {
            circle.handle = strdup(pair->value);
            
        } else if (pair->groupCode == 8) {
            //Layer string needs to be freed.
            circle.layer = strdup(pair->value);
        }
        if (pair->groupCode == 10) {
            circle.centre.x = atof(pair->value);
        }
        if (pair->groupCode == 20) {
            circle.centre.y = atof(pair->value);
        }
        if (pair->groupCode == 40) {
            circle.radius = atof(pair->value);
        }
        
        DXFReadLine(pair, fp);
        
    }
    
    return circle;
}


// Move a DXFEntity so its lower left vertex is at the origin
void DXFzero(DXFEntity *entity)
{
    DXFPolyline *polyline = &entity->geometry.polyline;
    
    if (DXFPolylineArea(polyline) < 0) {
        DXFReversePolyline(polyline);
    }
    
    DXFVertex vector = DXFbasePoint(polyline);
    
    // Reverse vector
    vector.x *= -1;
    vector.y *= -1;
    
    DXFmoveEntity(entity, &vector);
}


// Move a DXFEntity according to the given vector
void DXFmoveEntity(DXFEntity *entity, DXFVertex *vector)
{
    if (entity->type == DXFTypePolyline) {
        DXFmovePolyline(&entity->geometry.polyline, vector);
    } else if (entity->type == DXFTypeCircle) {
        DXFmoveCircle(&entity->geometry.circle, vector);
    }
    
    if (entity->entityCount > 0) {
        int count = entity->entityCount;
        DXFEntity *entities = entity->entities;
        
        for (int i = 0; i < count; i++) {
            DXFmoveEntity(&entities[i], vector);
        }
    }
}

// Move all vertices in polyline by given vector
void DXFmovePolyline(DXFPolyline *polyline, DXFVertex *vector)
{
    DXFVertex *vertices = polyline->vertices;
    int count = polyline->vertexCount;
    
    for (int i = 0; i < count; i++) {
        DXFmoveVertex(&vertices[i], vector);
    }
}


// Move circle by given vector
void DXFmoveCircle(DXFCircle *circle, DXFVertex *vector)
{
    circle->centre.x = circle->centre.x + vector->x;
    circle->centre.y = circle->centre.y + vector->y;
}


// Move vertex by given vector
void DXFmoveVertex(DXFVertex *vertex, DXFVertex *vector)
{
    vertex->x = vertex->x + vector->x;
    vertex->y = vertex->y + vector->y;
}


// Return signed area of non complex polygon
double DXFPolylineArea(DXFPolyline *polyline)
{
    double sum = 0.0, xi, yi, xj, yj;
    int count = polyline->vertexCount;
    DXFVertex *vertices = polyline->vertices;
    
    for (int i = 0, j = 1; i < count; j = (++i + 1) % count) {
        
        xi = vertices[i].x;
        yi = vertices[i].y;
        xj = vertices[j].x;
        yj = vertices[j].y;
        
        sum += (xi * yj) - (xj * yi);
    }
    
    return sum /= 2;
}


// Return signe darea of a triangle
double DXFTriangleArea(DXFVertex *a, DXFVertex *b, DXFVertex *c)
{
    double sum = 0.0;
    
    sum += (a->x * b->y) - (b->x * a->y);
    sum += (b->x * c->y) - (c->x * b->y);
    sum += (c->x * a->y) - (a->x * c->y);
    
    return sum /= 2;
}


// Reverse the order of vertices in a polyline
void DXFReversePolyline(DXFPolyline *polyline)
{
    DXFVertex *vertices = polyline->vertices;
    DXFVertex temp;
    int start = 0;
    int end = polyline->vertexCount - 1;
    
    while (start < end) {
        temp = vertices[start];
        vertices[start] = vertices[end];
        vertices[end] = temp;
        start++;
        end--;
    }
}


// Return lowest and leftmost vertex in a polyline
DXFVertex DXFbasePoint(DXFPolyline *polyline)
{
    DXFVertex basePoint;
    
    basePoint.x     = INFINITY;
    basePoint.y     = INFINITY;
    basePoint.bulge = 0.0;
    
    DXFVertex *vertices = polyline->vertices;
    
    for (int i = 0; i < polyline->vertexCount; i++) {
        if (vertices[i].x < basePoint.x || vertices[i].y < basePoint.y) {
            basePoint = vertices[i];
        }
    }
    
    return basePoint;
}


// Free an array of DXFEntitys
void DXFfree(DXFEntity *entities, int nEntities)
{
    for (int i = 0; i < nEntities; i++) {
        if (entities[i].type == DXFTypePolyline) {
            free(&entities[i].geometry.polyline.layer);
            free(&entities[i].geometry.polyline.vertices);

        } else if (entities[i].type == DXFTypeCircle) {
            free(&entities[i].geometry.circle.layer);
            
        }
        
        if (entities[i].entityCount > 0) {
            for (int j = 0; j < entities[i].entityCount; j++) {
                DXFfree(&entities[i].entities[j], entities[i].entityCount);
                
            }
        }
    }
}







