//
//  MATraceReplayOverlayRender.m
//  MAMapKit
//
//  Created by shaobin on 2017/4/20.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MATraceReplayOverlayRender.h"
#import "MATraceReplayOverlay.h"
#import "MATraceReplayOverlay+Addition.h"

@interface MATraceReplayOverlayRenderer () {
    MAMultiColoredPolylineRenderer *_proxyRender;
    NSTimeInterval _prevTime;
    
    MAPolylineRenderer *_patchLineRender;
    
    CGPoint _imageMapPoints[4];
    CGPoint _glPoints[4];
    GLuint _textureName;
}

@end

@implementation MATraceReplayOverlayRenderer

- (id)initWithOverlay:(id<MAOverlay>)overlay {
    if(![overlay isKindOfClass:[MATraceReplayOverlay class]]) {
        return nil;
    }
    
    self = [super initWithOverlay:overlay];
    if(self) {
        MATraceReplayOverlay *traceOverlay = (MATraceReplayOverlay*)overlay;
        _proxyRender = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:[traceOverlay getMultiPolyline]];
        _proxyRender.gradient = NO;
        _proxyRender.strokeColors = @[[UIColor grayColor], [UIColor greenColor]];
        _proxyRender.strokeColor = _proxyRender.strokeColors.lastObject;
        
        _patchLineRender = [[MAPolylineRenderer alloc] initWithPolyline:[traceOverlay getPatchPolyline]];
        _patchLineRender.strokeColor = _proxyRender.strokeColors.lastObject;
        
        _carImage = [UIImage imageNamed:@"userPosition"];
    }
    
    return self;
}

- (void)glRender
{
    MATraceReplayOverlay *traceOverlay = (MATraceReplayOverlay*)self.overlay;
    if(_prevTime == 0) {
        _prevTime = CFAbsoluteTimeGetCurrent();
        [traceOverlay drawStepWithTime:0 zoomLevel:[self getMapZoomLevel]];
    } else {
        NSTimeInterval curTime = CFAbsoluteTimeGetCurrent();
        [traceOverlay drawStepWithTime:curTime - _prevTime zoomLevel:[self getMapZoomLevel]];
        _prevTime = curTime;
    }
    
    if(self.carImage && [traceOverlay getMultiPolyline].pointCount > 0) {
        if(_textureName == 0) {
            _textureName = [self loadTexture:self.carImage];
        }
        
        MAMapPoint carPoint = [traceOverlay getCarPosition];
        CLLocationDirection rotate = [traceOverlay getRunningDirection];
        
        double zoomLevel = [self getMapZoomLevel];
        double zoomScale = pow(2, zoomLevel);
        
        CGSize imageSize = self.carImage.size;
        
        double halfWidth  = imageSize.width  * (1 << 20) / zoomScale/2;
        double halfHeight = imageSize.height * (1 << 20) / zoomScale/2;
        
        _imageMapPoints[0].x = -halfWidth;
        _imageMapPoints[0].y = halfHeight;
        _imageMapPoints[1].x = halfWidth;
        _imageMapPoints[1].y = halfHeight;
        _imageMapPoints[2].x = halfWidth;
        _imageMapPoints[2].y = -halfHeight;
        _imageMapPoints[3].x = -halfWidth;
        _imageMapPoints[3].y = -halfHeight;
        
        
        for(int i = 0; i < 4; ++i) {
            CGPoint tempPoint = _imageMapPoints[i];
            if(traceOverlay.enableAutoCarDirection) {
                tempPoint = CGPointApplyAffineTransform(_imageMapPoints[i], CGAffineTransformMakeRotation(rotate));
            }
            
            tempPoint.x += carPoint.x;
            tempPoint.y += carPoint.y;
            _glPoints[i] = [self glPointForMapPoint:MAMapPointMake(tempPoint.x, tempPoint.y)];
        }
        
        [_proxyRender glRender];
        [_patchLineRender glRender];
        
        [self renderIconWithTextureID:_textureName points:_glPoints];
    } else {
        [_proxyRender glRender];
    }
}

- (void)setRendererDelegate:(id<MAOverlayRenderDelegate>)rendererDelegate {
    [super setRendererDelegate:rendererDelegate];
    _proxyRender.rendererDelegate = rendererDelegate;
    _patchLineRender.rendererDelegate = rendererDelegate;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    [super setLineWidth:lineWidth];
    _proxyRender.lineWidth = lineWidth;
    _patchLineRender.lineWidth = lineWidth;
}

- (void)setStrokeColors:(NSArray *)strokeColors {
    if(strokeColors.count != 2) {
        return;
    }
    _proxyRender.strokeColors = strokeColors;
    
    if(strokeColors.count > 0) {
        _proxyRender.strokeColor = strokeColors.lastObject;
        _patchLineRender.strokeColor = strokeColors.lastObject;
    }
}

- (NSArray *)strokeColors {
    return _proxyRender.strokeColors;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    [super setStrokeColor:strokeColor];
    [_proxyRender setStrokeColor:strokeColor];
    [_patchLineRender setStrokeColor:strokeColor];
}

- (UIColor *)strokeColor {
    return _proxyRender.strokeColor;
}

@end

