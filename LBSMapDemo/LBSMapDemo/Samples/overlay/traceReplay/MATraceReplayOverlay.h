//
//  MATraceReplayOverlay.h
//  MAMapKit
//
//  Created by shaobin on 2017/4/20.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>

///轨迹回放overlay（since 5.1.0）
@interface MATraceReplayOverlay : NSObject<MAOverlay>

///是否启动点抽稀，默认YES
@property (nonatomic, assign) BOOL enablePointsReduce;

///小汽车移动速度，默认80 km/h, 单位米每秒
@property (nonatomic, assign) CGFloat speed;

///是否自动调整车头方向，默认NO
@property (nonatomic, assign) BOOL enableAutoCarDirection;

///是否暂停, 初始为YES
@property (nonatomic, assign) BOOL isPaused;

///各个点权重设置，取值1-5，5最大。权重为5则不对此点做抽稀。格式为：{weight:indices}
@property (nonatomic, strong) NSDictionary<NSNumber*, NSArray*> *pointsWeight;

/**
 * @brief 重置为初始状态
 */
- (void)reset;

/**
 * @brief 根据map point设置轨迹点
 * @param points map point数据,points对应的内存会拷贝,调用者负责该内存的释放
 * @param count  map point个数
 * @return 返回是否成功
 */
- (BOOL)setWithPoints:(MAMapPoint *)points count:(NSInteger)count;

/**
 * @brief 根据经纬度坐标设置轨迹点
 * @param coords 经纬度坐标数据,coords对应的内存会拷贝,调用者负责该内存的释放
 * @param count  经纬度坐标个数
 * @return 返回是否成功
 */
- (BOOL)setWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSInteger)count;

/**
 * @brief 获取当前car所在位置点索引
 */
- (NSInteger)getOrigPointIndexOfCar;

/**
 * @brief 获取抽稀后当前car所在位置点索引
 */
- (NSInteger)getReducedPointIndexOfCar;

/**
 * @brief 获取行进方向,in radian
 */
- (CGFloat)getRunningDirection;

/**
 * @brief 获取索引index对应的mapPoint
 */
- (MAMapPoint)getMapPointOfIndex:(NSInteger)origIndex;

/**
 * @brief 获取小车位置
 */
- (MAMapPoint)getCarPosition;

/**
 * @brief 预处理，加快后面的操作流畅度. 调用前不要把overlay加到mapview，在callback中再把overlay加到mapview
 */
- (void)prepareAsync:(void(^)())callback;

@end
