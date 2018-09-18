//
//  FaceOverlayRenderer.m
//  CustomOverlayViewDemo
//
//  Created by songjian on 13-3-12.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "FaceOverlayRenderer.h"

@interface FaceOverlayRenderer ()
{
    MAMapPoint *_leftCircleMapPoints;
    NSUInteger _leftCircleMapPointsCount;
    MAMapPoint *_rightCircleMapPoints;
    NSUInteger _rightCircleMapPointsCount;
    MAMapPoint _linePoints[2];
    
}

@end

@implementation FaceOverlayRenderer

#pragma mark - Utility

/* The caller should be responsible for releasing memory. */
- (MAMapPoint *)circleMapPointsForCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate radius:(CLLocationDistance)radius outCount:(NSUInteger *)outCount
{
    CGFloat hypotenuse = MAMapPointsPerMeterAtLatitude(centerCoordinate.latitude) * radius;
    MAMapPoint centerMapPoint = MAMapPointForCoordinate(centerCoordinate);
    
#define INCISION_PRECISION 360
    MAMapPoint *points = (MAMapPoint*)malloc(INCISION_PRECISION * sizeof(MAMapPoint));
    for (int i = 0; i < INCISION_PRECISION; i++)
    {
        CGFloat radian  = i * M_PI / 180.f;
        CGFloat xOffset = sin(radian) * hypotenuse;
        CGFloat yOffset = cos(radian) * hypotenuse;
        
        points[i].x = centerMapPoint.x + xOffset;
        points[i].y = centerMapPoint.y + yOffset;
    }
    
    if (outCount != NULL)
    {
        *outCount = INCISION_PRECISION;
    }
    
    return points;
}

- (void)drawCircleWithPoints:(CGPoint *)points pointCount:(NSUInteger)pointCount
{
    if (points == NULL || pointCount < 3)
    {
        return;
    }
    
    ///使用新方法
    [self renderStrokedRegionWithPoints:points pointCount:pointCount fillColor:self.fillColor strokeColor:self.strokeColor strokeLineWidth:[self glWidthForWindowWidth:self.lineWidth] strokeLineJoinType:self.lineJoinType strokeLineDash:YES usingTriangleFan:YES];
}

- (void)drawLineWithPoints:(CGPoint *)points pointCount:(NSUInteger)pointCount
{
    if (points == NULL || pointCount < 2)
    {
        return;
    }
    
    /* Drawing line. */
    [self renderLinesWithPoints:points pointCount:pointCount strokeColor:self.strokeColor lineWidth:[self glWidthForWindowWidth:self.lineWidth] looped:NO LineJoinType:self.lineJoinType LineCapType:self.lineCapType lineDash:self.lineDashType];
}

#pragma mark - Interface

- (FaceOverlay *)faceOverlay
{
    return (FaceOverlay*)self.overlay;
}

#pragma mark - Override

- (void)glRender
{
    /* Drawing left circle. */
    CGPoint *glPoints = [self glPointsForMapPoints:_leftCircleMapPoints count:_leftCircleMapPointsCount];
    [self drawCircleWithPoints:glPoints pointCount:_leftCircleMapPointsCount];
    
    /* Drawing right circle. */
    CGPoint *glPoints2 = [self glPointsForMapPoints:_rightCircleMapPoints count:_rightCircleMapPointsCount];
    [self drawCircleWithPoints:glPoints2 pointCount:_rightCircleMapPointsCount];
    
    /* Drawing line. */
    CGPoint *glPoints3 = [self glPointsForMapPoints:_linePoints count:2];
    [self drawLineWithPoints:glPoints3 pointCount:2];
    
    free(glPoints);
    free(glPoints2);
    free(glPoints3);
}

#pragma mark - Life Cycle

- (void)initMapPoints
{
    FaceOverlay *faceOverlay = (FaceOverlay*)self.overlay;
    NSUInteger count = 0;
    
    _leftCircleMapPoints = [self circleMapPointsForCenterCoordinate:faceOverlay.leftEyeCoordinate radius:faceOverlay.leftEyeRadius outCount:&count];
    _leftCircleMapPointsCount = count;
    
    _rightCircleMapPoints = [self circleMapPointsForCenterCoordinate:faceOverlay.rightEyeCoordinate radius:faceOverlay.rightEyeRadius outCount:&count];
    _rightCircleMapPointsCount = count;
    
    _linePoints[0] = MAMapPointForCoordinate(faceOverlay.leftEyeCoordinate);
    _linePoints[1] = MAMapPointForCoordinate(faceOverlay.rightEyeCoordinate);
}

- (id)initWithFaceOverlay:(FaceOverlay *)faceOverlay;
{
    self = [super initWithOverlay:faceOverlay];
    if (self)
    {
        [self initMapPoints];
    }
    
    return self;
}

- (void)dealloc
{
    if (_leftCircleMapPoints != NULL)
    {
        free(_leftCircleMapPoints), _leftCircleMapPoints = NULL;
    }
    
    if (_rightCircleMapPoints != NULL)
    {
        free(_rightCircleMapPoints), _rightCircleMapPoints = NULL;
    }
    
}

@end
