//
//  MATraceReplayOverlayRender.h
//  MAMapKit
//
//  Created by shaobin on 2017/4/20.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

///轨迹回放overlay渲染器（since 5.1.0）
@interface MATraceReplayOverlayRenderer : MAOverlayPathRenderer

///轨迹回放图标，会沿轨迹平滑移动
@property (nonatomic, strong) UIImage *carImage;

///分段绘制的颜色,需要分段颜色绘制时，数组大小必须是2，第一个颜色是走过轨迹的颜色，第二个颜色是未走过的
@property (nonatomic, strong) NSArray *strokeColors;

@end
