//
//  MATraceReplayOverlay.m
//  MAMapKit
//
//  Created by shaobin on 2017/4/20.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MATraceReplayOverlay.h"
#import "MATraceReplayOverlay+Addition.h"

struct MATraceReplayPoint{
    double x;           ///<x坐标
    double y;           ///<y坐标
    int    weight;      ///<权重
    int    flag;        ///<标志位, 1保留，0去除
    double distance;    ///<和下一点的距离
};

typedef struct MATraceReplayPoint MATraceReplayPoint;

@interface MATraceReplayOverlay () {
    MAMultiPolyline *_multiPolyline;
    MAPolyline *_patchLine; //小车位置到下一个轨迹点的线段
    MAMapPoint _patchLinePoints[2];
    
    MATraceReplayPoint *_origMapPoints;
    NSInteger _origPointCount;
    
    NSInteger _carIndexInOrigArray;
    NSInteger _reducedPointIndexOfCar;
    
    BOOL _needRecalculateMapPoints;
    
    CGFloat _zoomLevel;
    
    CGFloat _accumulatedDistance;
    MAMapPoint _carMapPoint;
    CGFloat _runningDirection;
    
    BOOL _readyForDrawing;
    
    NSMutableDictionary *_reducedPointsCache; //{zoomLevel:IndexArray}
}

@end

@implementation MATraceReplayOverlay

- (id)init {
    self = [super init];
    
    if(self) {
        
        self.isPaused = YES;
        _multiPolyline = [MAMultiPolyline polylineWithCoordinates:NULL count:0 drawStyleIndexes:nil];
        _patchLine = [MAPolyline polylineWithPoints:NULL count:0];
        _enablePointsReduce = YES;
        _zoomLevel = 0;
        _speed = 80.0*1000/3600;
        
        _reducedPointsCache = [NSMutableDictionary dictionaryWithCapacity:20];
        
    }
    
    return self;
}

- (void)dealloc {
    if(_origMapPoints) {
        free(_origMapPoints);
    }
}

- (void)setEnablePointsReduce:(BOOL)enablePointsReduce {
    if(_enablePointsReduce != enablePointsReduce) {
        _enablePointsReduce = enablePointsReduce;
        _needRecalculateMapPoints = YES;
    }
}

- (void)reset {
    self.isPaused = YES;
    _carIndexInOrigArray = 0;
    _multiPolyline.drawStyleIndexes = nil;
    _readyForDrawing = NO;
}

- (BOOL)setWithPoints:(MAMapPoint *)points count:(NSInteger)count {
    if(points == NULL || count <= 0) {
        if (_origMapPoints != NULL) {
            free(_origMapPoints), _origMapPoints = NULL;
        }
        _origPointCount = 0;
        
        [_reducedPointsCache removeAllObjects];
        
        _needRecalculateMapPoints = YES;
        [self recalculateMapPoints];
        
        return YES;
    }
    
    MATraceReplayPoint *oldPoints = _origMapPoints;
    _origMapPoints = (MATraceReplayPoint*)malloc(count * sizeof(MATraceReplayPoint));
    if(_origMapPoints == NULL) {
        _origMapPoints = oldPoints;
        return NO;
    }
    
    _origPointCount = count;
    MATraceReplayPoint *curP1 = _origMapPoints;
    MAMapPoint *curP2 = points;
    for(int i = 0; i < count; ++i) {
        curP1->x = curP2->x;
        curP1->y = curP2->y;
        curP1->weight = 1;
        curP1->flag = 1;
        
        curP1++;
        curP2++;
    }
    
    for(int i = 0; i < count - 1; ++i) {
        MAMapPoint p1 = MAMapPointMake(_origMapPoints[i].x, _origMapPoints[i].y);
        MAMapPoint p2 = MAMapPointMake(_origMapPoints[i+1].x, _origMapPoints[i+1].y);
        _origMapPoints[i].distance = MAMetersBetweenMapPoints(p1, p2);
    }
    
    if(oldPoints != NULL) {
        free(oldPoints);
    }
    
    [_reducedPointsCache removeAllObjects];
    
    _needRecalculateMapPoints = YES;
    [self recalculateMapPoints];
    
    return YES;
}

- (BOOL)setWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSInteger)count {
    if(coords == NULL || count <= 0) {
        if (_origMapPoints != NULL) {
            free(_origMapPoints), _origMapPoints = NULL;
        }
        _origPointCount = 0;
        
        [_reducedPointsCache removeAllObjects];
        
        _needRecalculateMapPoints = YES;
        [self recalculateMapPoints];
        
        return YES;
    }
    
    MATraceReplayPoint *oldPoints = _origMapPoints;
    _origMapPoints = (MATraceReplayPoint*)malloc(count * sizeof(MATraceReplayPoint));
    if(_origMapPoints == NULL) {
        _origMapPoints = oldPoints;
        return NO;
    }
    
    _origPointCount = count;
    MATraceReplayPoint *curP1 = _origMapPoints;
    for(int i = 0; i < count; ++i) {
        MAMapPoint p = MAMapPointForCoordinate(coords[i]);
        curP1->x = p.x;
        curP1->y = p.y;
        curP1->weight = 1;
        curP1->flag = 1;
        
        curP1++;
    }
    
    for(int i = 0; i < count - 1; ++i) {
        MAMapPoint p1 = MAMapPointMake(_origMapPoints[i].x, _origMapPoints[i].y);
        MAMapPoint p2 = MAMapPointMake(_origMapPoints[i+1].x, _origMapPoints[i+1].y);
        _origMapPoints[i].distance = MAMetersBetweenMapPoints(p1, p2);
    }
    
    if(oldPoints != NULL) {
        free(oldPoints);
    }
    
    [_reducedPointsCache removeAllObjects];
    
    _needRecalculateMapPoints = YES;
    [self recalculateMapPoints];
    
    return YES;
}

- (void)setPointsWeight:(NSDictionary<NSNumber *,NSArray *> *)pointsWeight {
    _pointsWeight = pointsWeight;
    for(NSNumber *key in [pointsWeight allKeys]) {
        int weight = key.intValue;
        if(weight > 5 || weight < 1) {
            continue;
        }
        
        NSArray *indices = [pointsWeight objectForKey:key];
        for(NSNumber *index in indices) {
            int i = index.intValue;
            if(i < _origPointCount) {
                _origMapPoints[i].weight = weight;
            }
        }
    }
    
    [_reducedPointsCache removeAllObjects];
    
    _needRecalculateMapPoints = YES;
    [self recalculateMapPoints];
}

- (NSInteger)getOrigPointIndexOfCar {
    return _carIndexInOrigArray;
}

- (NSInteger)getReducedPointIndexOfCar {
    if(!_enablePointsReduce) {
        return [self getOrigPointIndexOfCar];
    }
    
    return _reducedPointIndexOfCar;
}

- (CGFloat)getRunningDirection {
    return _runningDirection;
}

- (MAMapPoint)getMapPointOfIndex:(NSInteger)origIndex {
    if(origIndex >= _origPointCount) {
        return MAMapPointMake(0, 0);
    }
    return MAMapPointMake(_origMapPoints[origIndex].x, _origMapPoints[origIndex].y);
}

- (MAMapPoint)getCarPosition {
    return _carMapPoint;
}

#pragma mark - overlay
- (MAMapRect)boundingMapRect {
    if(_needRecalculateMapPoints) {
        return MAMapRectWorld;
    }
    return _multiPolyline.boundingMapRect;
}

- (CLLocationCoordinate2D)coordinate {
    MAMapRect boundimgMapRect = [self boundingMapRect];
    return MACoordinateForMapPoint(MAMapPointMake(MAMapRectGetMidX(boundimgMapRect), MAMapRectGetMidY(boundimgMapRect)));
}

#pragma mark - addition
- (MAMultiPolyline *)getMultiPolyline {
    return _multiPolyline;
}

- (MAPolyline *)getPatchPolyline {
    return _patchLine;
}

- (void)drawStepWithTime:(NSTimeInterval)timeDelta zoomLevel:(CGFloat)zoomLevel {
    [self setZoomLevel:zoomLevel];
    
    BOOL hasRecalculated = [self recalculateMapPoints];
    //计算小车位置索引
    if(!_isPaused || !_readyForDrawing || hasRecalculated) {
        if(_isPaused) {
            timeDelta = 0;
        }
        
        //计算最后一个flag=1的点的索引
        NSInteger theLastIndex = _origPointCount - 1;
        while(theLastIndex > 0 && _origMapPoints[theLastIndex].flag != 1) {
            theLastIndex--;
        }
        
        NSInteger curIndex = _carIndexInOrigArray;
        if(curIndex == _origPointCount) {
            _carMapPoint = MAMapPointMake(_origMapPoints[theLastIndex].x, _origMapPoints[theLastIndex].y);
            [_patchLine setPolylineWithPoints:NULL count:0];
            _multiPolyline.drawStyleIndexes = @[@(_multiPolyline.pointCount - 1)];
            
            _runningDirection = MAGetDirectionFromPoints(_multiPolyline.points[_multiPolyline.pointCount - 2], _multiPolyline.points[_multiPolyline.pointCount - 1]) * M_PI / 180;
            self.isPaused = YES;
            return;
        }
        
        double deltaDistance = _speed * timeDelta;
        _accumulatedDistance += deltaDistance;
        while(curIndex < _origPointCount) {
            double distance = _origMapPoints[curIndex].distance;
            if(_accumulatedDistance > distance) {
                curIndex++;
                _accumulatedDistance -= distance;
                
            } else {
                break;
            }
        }
        
        _carIndexInOrigArray = curIndex;
        
        if(curIndex == _origPointCount) {
            _carMapPoint = MAMapPointMake(_origMapPoints[theLastIndex].x, _origMapPoints[theLastIndex].y);
            [_patchLine setPolylineWithPoints:NULL count:0];
            _multiPolyline.drawStyleIndexes = @[@(_multiPolyline.pointCount - 1)];
            
            _runningDirection = MAGetDirectionFromPoints(_multiPolyline.points[_multiPolyline.pointCount - 2], _multiPolyline.points[_multiPolyline.pointCount - 1]) * M_PI / 180;
            self.isPaused = YES;
            return;
        }
        
        //计算当前小车所在polyline的子线段的端点索引
        NSInteger prevIndex = curIndex;
        NSInteger nextIndex = curIndex + 1;
        while(prevIndex > 0 && _origMapPoints[prevIndex].flag != 1) {
            prevIndex--;
        }
        while(nextIndex <= theLastIndex && _origMapPoints[nextIndex].flag != 1) {
            nextIndex++;
        }
        
        //计算小车位置
        double passedDistance = 0;
        for(NSInteger i = prevIndex; i < curIndex; ++i) {
            passedDistance += _origMapPoints[i].distance;
        }
        double totalDistance = passedDistance;
        for(NSInteger i = curIndex; i < nextIndex; ++i) {
            totalDistance += _origMapPoints[i].distance;
        }
        float ratio = (passedDistance + _accumulatedDistance) / totalDistance;
        
        MAMapPoint p1 = MAMapPointMake(_origMapPoints[prevIndex].x, _origMapPoints[prevIndex].y);
        MAMapPoint p2 = MAMapPointMake(_origMapPoints[nextIndex].x, _origMapPoints[nextIndex].y);
        _carMapPoint.x = p1.x + ratio * (p2.x - p1.x);
        _carMapPoint.y = p1.y + ratio * (p2.y - p1.y);
        
        //计算小车方向
        _runningDirection = MAGetDirectionFromPoints(MAMapPointMake(p1.x, p1.y), MAMapPointMake(p2.x, p2.y)) * M_PI / 180;
        
        //更新小车在polyline里的索引
        NSInteger ret = 0;
        for(int i = 0; i < prevIndex; ++i) {
            if(_origMapPoints[i].flag == 1) {
                ret++;
            }
        }
        _reducedPointIndexOfCar = ret;
        
        //更新polyline的drawIndex
        if(_carIndexInOrigArray == 0) {
            _multiPolyline.drawStyleIndexes = nil;
            //更新patchline
            [_patchLine setPolylineWithPoints:NULL count:0];
        } else {
            _multiPolyline.drawStyleIndexes = @[@(_reducedPointIndexOfCar + 1)];
            
            //更新patchline
            _patchLinePoints[0] = _carMapPoint;
            _patchLinePoints[1] = p2;
            [_patchLine setPolylineWithPoints:_patchLinePoints count:2];
        }
    }
    
    if(!_readyForDrawing) {
        _readyForDrawing = YES;
    }
}

#pragma mark - private
- (void)setZoomLevel:(CGFloat)zoomLevel {
    int prevZoomLevel = floor(_zoomLevel);
    int currentoomLevel = floor(zoomLevel);
    if(prevZoomLevel != currentoomLevel) {
        _needRecalculateMapPoints = YES;
    }
    
    _zoomLevel = zoomLevel;
}

- (void)reducer_RDP:(MATraceReplayPoint *)inPoints
          fromIndex:(NSInteger)fromIndex
            toIndex:(NSInteger)toIndex
         threshHold:(float)threshHold {
    NSInteger count = toIndex - fromIndex + 1;
    if(count <= 2) {
        for(NSInteger i = 0; i < count; ++i) {
            inPoints[i].flag = 1;
        }
        return;
    }
    
    double max = 0;
    NSInteger index = 0;
    MAMapPoint firstPoint =  MAMapPointMake(inPoints[fromIndex].x, inPoints[fromIndex].y);
    MAMapPoint lastPoint = MAMapPointMake(inPoints[toIndex].x, inPoints[toIndex].y);
    for(NSInteger i = fromIndex; i <= toIndex; ++i) {
        MAMapPoint curP = MAMapPointMake(inPoints[i].x, inPoints[i].y);
        double d = MAGetDistanceFromPointToLine(curP, firstPoint, lastPoint);
        if(d > max) {
            index = i;
            max = d;
        }
    }
    
    if(max < threshHold) {
        inPoints[fromIndex].flag = 1;
        inPoints[toIndex].flag = 1;
    } else {
        [self reducer_RDP:inPoints fromIndex:fromIndex toIndex:index threshHold:threshHold];
        [self reducer_RDP:inPoints fromIndex:index toIndex:toIndex threshHold:threshHold];
    }
}

- (BOOL)recalculateMapPoints {
    if(!_needRecalculateMapPoints) {
        return NO;
    }
    
    ///重新做抽稀
    if(_enablePointsReduce) {
        int zoomLevel = floor(_zoomLevel);
        NSNumber *key = @(zoomLevel);
        NSArray *indexArray = [_reducedPointsCache objectForKey:key];
        
        for(NSInteger i = 0; i < _origPointCount; ++i) {
            _origMapPoints[i].flag = 0;
        }
        
        if(!indexArray) {
            CGFloat metersPerPixel = exp2(19 - zoomLevel);
            metersPerPixel = fmax(1, metersPerPixel);
            [self reducer_RDP:_origMapPoints fromIndex:0 toIndex:_origPointCount - 1 threshHold:metersPerPixel];
            
            NSMutableArray<NSNumber*> *tempArr = [NSMutableArray array];
            for(NSInteger i = 0; i < _origPointCount; ++i) {
                if(_origMapPoints[i].flag == 1 || _origMapPoints[i].weight == 5) {
                    [tempArr addObject:@(i)];
                }
            }
            
            indexArray = tempArr;
            
            [_reducedPointsCache setObject:indexArray forKey:key];
        }
        
        if (indexArray.count > 0) {
            for(NSNumber *indexObj in indexArray) {
                int index = indexObj.intValue;
                _origMapPoints[index].flag = 1;
            }
            
            NSInteger count = indexArray.count;
            MAMapPoint *p = (MAMapPoint *)malloc(sizeof(MAMapPoint) * count);
            if(p) {
                for(int i = 0; i < count; ++i) {
                    NSNumber *indexObj = [indexArray objectAtIndex:i];
                    int index = indexObj.intValue;
                    p[i].x = _origMapPoints[index].x;
                    p[i].y = _origMapPoints[index].y;
                }
                [_multiPolyline setPolylineWithPoints:p count:count drawStyleIndexes:nil];
                
                free(p);
            }
        }
        
    } else {
        MAMapPoint *p = (MAMapPoint *)malloc(sizeof(MAMapPoint) * _origPointCount);
        if(p) {
            for(int i = 0; i < _origPointCount; ++i) {
                p[i].x = _origMapPoints[i].x;
                p[i].y = _origMapPoints[i].y;
            }
            [_multiPolyline setPolylineWithPoints:p count:_origPointCount drawStyleIndexes:nil];
            
            free(p);
        }
    }
    
    _needRecalculateMapPoints = NO;
    return YES;
}

- (void)prepareAsync:(void(^)())callback {
    if([NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [weakSelf prepareAsync:callback];
        });
    } else {
        for(NSInteger i = 0; i < _origPointCount; ++i) {
            _origMapPoints[i].flag = 0;
        }
        
        for(int zoomLevel = 3; zoomLevel <= 20; ++zoomLevel) {
            CGFloat metersPerPixel = exp2(19 - zoomLevel);
            metersPerPixel = fmax(1, metersPerPixel);
            [self reducer_RDP:_origMapPoints fromIndex:0 toIndex:_origPointCount - 1 threshHold:metersPerPixel];
            
            NSMutableArray<NSNumber*> *tempArr = [NSMutableArray array];
            for(NSInteger i = 0; i < _origPointCount; ++i) {
                if(_origMapPoints[i].flag == 1 || _origMapPoints[i].weight == 5) {
                    [tempArr addObject:@(i)];
                }
            }
            
            [_reducedPointsCache setObject:tempArr forKey:@(zoomLevel)];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(callback) {
                callback();
            }
        });
    }
}
@end
