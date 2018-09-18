//
//  MATraceReplayOverlay+Addition.h
//  MAMapKit
//
//  Created by shaobin on 2017/4/20.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MATraceReplayOverlay.h"

@interface MATraceReplayOverlay (Addition)

/**
 * @brief 每次帧绘制时调用
 * @param timeDelta 时间
 * @param zoomLevel 地图zoom
 */
- (void)drawStepWithTime:(NSTimeInterval)timeDelta zoomLevel:(CGFloat)zoomLevel;

/**
 * @brief 获取内部mutlipolyine
 */
- (MAMultiPolyline *)getMultiPolyline;

/**
 * @brief 获取内部patchLine
 */
- (MAPolyline *)getPatchPolyline;

@end
